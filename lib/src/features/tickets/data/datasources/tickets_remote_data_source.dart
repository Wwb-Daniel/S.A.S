import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart' as mime;

import '../../domain/models/ticket.dart';
import '../../domain/models/ticket_filters.dart';

class TicketsRemoteDataSource {
  final SupabaseClient _client;
  TicketsRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const String _cloudName = 'dtxikv1nx';
  static const String _uploadPreset = 'uploads_unsigned';

  Future<List<Ticket>> listTickets({TicketFilters? filters}) async {
    var query = _client.from('tickets').select('*');

    if (filters != null) {
      if (filters.status != null && filters.status!.isNotEmpty) {
        query = query.eq('status', filters.status!);
      }
      if (filters.priority != null && filters.priority!.isNotEmpty) {
        query = query.eq('priority', filters.priority!);
      }
      final categoryId = filters.categoryId;
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (filters.assignedTo != null && filters.assignedTo!.isNotEmpty) {
        query = query.eq('assigned_to', filters.assignedTo!);
      }
      if (filters.createdBy != null && filters.createdBy!.isNotEmpty) {
        query = query.eq('created_by', filters.createdBy!);
      }
      if (filters.startDate != null) {
        query = query.gte('created_at', filters.startDate!.toUtc().toIso8601String());
      }
      if (filters.endDate != null) {
        query = query.lte('created_at', filters.endDate!.toUtc().toIso8601String());
      }
      if (filters.isOverdue == true) {
        final now = DateTime.now().toUtc().toIso8601String();
        query = query.lt('due_date', now).neq('status', 'resuelto').neq('status', 'cerrado');
      }
      if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
        // Usa la función search_tickets si existe, si no, fallback simple por título y descripción
        try {
          final data = await _client.rpc('search_tickets', params: {'search_term': filters.searchQuery});
          if (data is List) {
            return data.map((e) => Ticket.fromMap(Map<String, dynamic>.from(e as Map))).toList();
          }
        } catch (_) {
          query = query.or('title.ilike.%${filters.searchQuery}%,description.ilike.%${filters.searchQuery}%');
        }
      }
    }

    final List<dynamic> rows = await query.order('created_at', ascending: false);
    return rows.map((e) => Ticket.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<Ticket> createTicket({
    required String title,
    required String description,
    String priority = 'media',
    int? categoryId,
    DateTime? dueDate,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    // Obtener company_id del usuario actual via RPC existente
    final companyId = await _client.rpc('get_current_user_company_id');
    if (companyId == null) {
      throw Exception('No se pudo obtener la compañía del usuario');
    }

    final payload = {
      'title': title,
      'description': description,
      'priority': priority,
      if (categoryId != null) 'category_id': categoryId,
      'company_id': companyId as String,
      'created_by': user.id,
      if (dueDate != null) 'due_date': dueDate.toUtc().toIso8601String(),
    };

    final inserted = await _client
        .from('tickets')
        .insert(payload)
        .select()
        .single();

    return Ticket.fromMap(Map<String, dynamic>.from(inserted as Map));
  }

  Future<Ticket> getTicket(String id) async {
    final data = await _client.from('tickets').select('*').eq('id', id).single();
    return Ticket.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<List<Map<String, dynamic>>> _selectList(String table, Map<String, dynamic> filters, {String? orderBy, bool ascending = true}) async {
    var q = _client.from(table).select('*');
    filters.forEach((k, v) => q = q.eq(k, v));
    if (orderBy != null) {
      final res = await q.order(orderBy, ascending: ascending);
      return (res as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    final res = await q;
    return (res as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> listCommentsRaw(String ticketId) async {
    return _selectList('ticket_comments', {'ticket_id': ticketId}, orderBy: 'created_at', ascending: true);
  }

  Future<List<Map<String, dynamic>>> listAttachmentsRaw(String ticketId) async {
    return _selectList('ticket_attachments', {'ticket_id': ticketId}, orderBy: 'uploaded_at', ascending: false);
  }

  Future<Map<String, dynamic>> uploadAttachmentBytes({
    required Uint8List bytes,
    required String fileName,
    required String ticketId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final safeName = fileName.isEmpty
        ? 'ticket_${ticketId}_${DateTime.now().millisecondsSinceEpoch}.jpg'
        : fileName;

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/'+_cloudName+'/auto/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['public_id'] = 'tickets/$ticketId/$safeName'
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: safeName));

    final streamed = await request.send();
    final responseHttp = await http.Response.fromStream(streamed);
    if (responseHttp.statusCode < 200 || responseHttp.statusCode >= 300) {
      throw Exception('Cloudinary error ${responseHttp.statusCode}: ${responseHttp.body}');
    }
    final data = json.decode(responseHttp.body) as Map<String, dynamic>;
    final secureUrl = (data['secure_url'] ?? data['url']) as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary no devolvió URL');
    }

    final fileType = mime.lookupMimeType(safeName) ?? 'application/octet-stream';
    final payload = {
      'ticket_id': ticketId,
      'file_name': safeName,
      'file_path': 'tickets/$ticketId/$safeName',
      'file_url': secureUrl,
      'file_type': fileType,
      'file_size': bytes.length,
      'uploaded_by': user.id,
    };

    final inserted = await _client.from('ticket_attachments').insert(payload).select().single();
    return Map<String, dynamic>.from(inserted as Map);
  }

  Future<Ticket> updateTicketFields(String id, {String? status, String? priority, DateTime? dueDate}) async {
    final updates = <String, dynamic>{};
    if (status != null) updates['status'] = status;
    if (priority != null) updates['priority'] = priority;
    if (dueDate != null) updates['due_date'] = dueDate.toUtc().toIso8601String();
    if (updates.isEmpty) {
      return getTicket(id);
    }
    final row = await _client.from('tickets').update(updates).eq('id', id).select().single();
    return Ticket.fromMap(Map<String, dynamic>.from(row as Map));
  }

  Future<Map<String, dynamic>> createComment({
    required String ticketId,
    required String content,
    bool isInternal = false,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final payload = {
      'ticket_id': ticketId,
      'employee_id': user.id,
      'comment': content,
      'is_internal': isInternal,
    };
    final row = await _client.from('ticket_comments').insert(payload).select().single();
    return Map<String, dynamic>.from(row as Map);
  }

  Future<void> deleteAttachment(String attachmentId) async {
    await _client.from('ticket_attachments').delete().eq('id', attachmentId);
  }
}

import 'package:dartz/dartz.dart';
import 'package:mi_app_multiplataforma/src/core/error/failures.dart';

import '../../domain/models/ticket.dart';
import '../../domain/models/ticket_comment.dart';
import '../../domain/models/ticket_attachment.dart';
import '../../domain/models/ticket_filters.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../datasources/tickets_remote_data_source.dart';
import 'dart:typed_data';

class TicketsRepositoryImpl implements TicketsRepository {
  final TicketsRemoteDataSource remote;
  TicketsRepositoryImpl({TicketsRemoteDataSource? remote})
      : remote = remote ?? TicketsRemoteDataSource();

  @override
  Future<Either<Failure, List<Ticket>>> listTickets({TicketFilters? filters}) async {
    try {
      final data = await remote.listTickets(filters: filters);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure('Error al listar tickets: $e'));
    }
  }

  @override
  Future<Either<Failure, Ticket>> createTicket({
    required String title,
    required String description,
    String priority = 'media',
    int? categoryId,
    DateTime? dueDate,
  }) async {
    try {
      final t = await remote.createTicket(
        title: title,
        description: description,
        priority: priority,
        categoryId: categoryId,
        dueDate: dueDate,
      );
      return Right(t);
    } catch (e) {
      return Left(ServerFailure('Error al crear ticket: $e'));
    }
  }

  @override
  Future<Either<Failure, Ticket>> getTicket(String id) async {
    try {
      final t = await remote.getTicket(id);
      return Right(t);
    } catch (e) {
      return Left(ServerFailure('Error al obtener ticket: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TicketComment>>> listComments(String ticketId) async {
    try {
      final rows = await remote.listCommentsRaw(ticketId);
      final list = rows.map((m) => TicketComment.fromMap(m)).toList();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure('Error al listar comentarios: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TicketAttachment>>> listAttachments(String ticketId) async {
    try {
      final rows = await remote.listAttachmentsRaw(ticketId);
      final list = rows.map((m) => TicketAttachment.fromMap(m)).toList();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure('Error al listar adjuntos: $e'));
    }
  }

  @override
  Future<Either<Failure, TicketAttachment>> uploadAttachmentBytes({
    required String ticketId,
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      final map = await remote.uploadAttachmentBytes(
        bytes: Uint8List.fromList(bytes),
        fileName: fileName,
        ticketId: ticketId,
      );
      return Right(TicketAttachment.fromMap(map));
    } catch (e) {
      return Left(ServerFailure('Error al subir adjunto: $e'));
    }
  }

  @override
  Future<Either<Failure, Ticket>> updateTicketFields(String id, {String? status, String? priority, DateTime? dueDate}) async {
    try {
      final t = await remote.updateTicketFields(id, status: status, priority: priority, dueDate: dueDate);
      return Right(t);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar ticket: $e'));
    }
  }

  @override
  Future<Either<Failure, TicketComment>> createComment({required String ticketId, required String content, bool isInternal = false}) async {
    try {
      final row = await remote.createComment(ticketId: ticketId, content: content, isInternal: isInternal);
      return Right(TicketComment.fromMap(row));
    } catch (e) {
      return Left(ServerFailure('Error al crear comentario: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAttachment(String attachmentId) async {
    try {
      await remote.deleteAttachment(attachmentId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar adjunto: $e'));
    }
  }
}

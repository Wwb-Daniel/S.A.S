import 'package:flutter/foundation.dart';

@immutable
class TicketAttachment {
  final String id;
  final String ticketId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final String uploadedBy;
  final DateTime uploadedAt;

  const TicketAttachment({
    required this.id,
    required this.ticketId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  factory TicketAttachment.fromMap(Map<String, dynamic> map) {
    return TicketAttachment(
      id: map['id'] as String,
      ticketId: map['ticket_id'] as String,
      fileName: map['file_name'] as String,
      fileUrl: map['file_url'] as String,
      fileType: map['file_type'] as String,
      fileSize: (map['file_size'] as num).toInt(),
      uploadedBy: map['uploaded_by'] as String,
      uploadedAt: DateTime.parse(map['uploaded_at'] as String),
    );
  }
}

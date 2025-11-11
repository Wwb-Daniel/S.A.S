import 'package:dartz/dartz.dart';

import '../../../../../src/core/error/failures.dart';
import '../models/ticket.dart';
import '../models/ticket_comment.dart';
import '../models/ticket_attachment.dart';
import '../models/ticket_filters.dart';

abstract class TicketsRepository {
  Future<Either<Failure, List<Ticket>>> listTickets({TicketFilters? filters});
  Future<Either<Failure, Ticket>> createTicket({
    required String title,
    required String description,
    String priority,
    int? categoryId,
    DateTime? dueDate,
  });
  Future<Either<Failure, Ticket>> getTicket(String id);
  Future<Either<Failure, List<TicketComment>>> listComments(String ticketId);
  Future<Either<Failure, List<TicketAttachment>>> listAttachments(String ticketId);
  Future<Either<Failure, TicketAttachment>> uploadAttachmentBytes({
    required String ticketId,
    required List<int> bytes,
    required String fileName,
  });
  Future<Either<Failure, Ticket>> updateTicketFields(String id, {String? status, String? priority, DateTime? dueDate});
  Future<Either<Failure, TicketComment>> createComment({required String ticketId, required String content, bool isInternal});
  Future<Either<Failure, Unit>> deleteAttachment(String attachmentId);
}

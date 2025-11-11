import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum ExportFormat { pdf, word, excel }

class ExportService {
  /// Exporta una lista de tickets al formato especificado
  Future<String> exportTickets({
    required List<Map<String, dynamic>> tickets,
    required ExportFormat format,
    String? companyName,
  }) async {
    switch (format) {
      case ExportFormat.pdf:
        return await _exportToPDF(tickets, companyName);
      case ExportFormat.word:
        return await _exportToWord(tickets, companyName);
      case ExportFormat.excel:
        return await _exportToExcel(tickets, companyName);
    }
  }

  /// Método público para guardar archivos (usado por CSV y JSON)
  Future<String> saveFile({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    return await _saveFile(bytes, fileName, mimeType);
  }

  /// Exporta a PDF con diseño profesional
  Future<String> _exportToPDF(
    List<Map<String, dynamic>> tickets,
    String? companyName,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // Página de portada
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Encabezado con logo (placeholder)
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    companyName ?? 'Sistema de Tickets',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${now.day}/${now.month}/${now.year}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            
            // Título
            pw.Center(
              child: pw.Text(
                'Reporte de Tickets',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Total de tickets: ${tickets.length}',
                style: const pw.TextStyle(fontSize: 14),
              ),
            ),
            pw.SizedBox(height: 30),
            
            // Tabla de tickets
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                // Encabezados
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('ID', isHeader: true),
                    _buildTableCell('Título', isHeader: true),
                    _buildTableCell('Estado', isHeader: true),
                    _buildTableCell('Prioridad', isHeader: true),
                    _buildTableCell('Fecha', isHeader: true),
                  ],
                ),
                // Datos
                ...tickets.map((ticket) {
                  final id = ticket['id']?.toString() ?? '';
                  final shortId = id.length > 8 ? id.substring(0, 8) : id;
                  return pw.TableRow(
                    children: [
                      _buildTableCell(shortId),
                      _buildTableCell(ticket['title']?.toString() ?? ''),
                      _buildTableCell(ticket['status']?.toString() ?? ''),
                      _buildTableCell(ticket['priority']?.toString() ?? ''),
                      _buildTableCell(
                        ticket['created_at'] != null
                            ? DateTime.parse(ticket['created_at']).toString().split(' ')[0]
                            : '',
                      ),
                    ],
                  );
                }),
              ],
            ),
            
            // Pie de página con QR (placeholder)
            pw.Spacer(),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Generado el ${now.day}/${now.month}/${now.year} a las ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Generar archivo
    final bytes = await pdf.save();
    return await _saveFile(bytes, 'reporte_tickets_${now.millisecondsSinceEpoch}.pdf', 'application/pdf');
  }

  /// Exporta a Word (DOCX) usando docx_template
  Future<String> _exportToWord(
    List<Map<String, dynamic>> tickets,
    String? companyName,
  ) async {
    // Nota: docx_template requiere plantillas, aquí generamos un documento básico
    // Para una implementación completa, se necesitaría una plantilla .docx
    
    // Por ahora, generamos un archivo de texto formateado que puede abrirse en Word
    final buffer = StringBuffer();
    final now = DateTime.now();
    
    buffer.writeln('REPORTE DE TICKETS');
    buffer.writeln('${companyName ?? "Sistema de Tickets"}');
    buffer.writeln('Fecha: ${now.day}/${now.month}/${now.year}');
    buffer.writeln('');
    buffer.writeln('Total de tickets: ${tickets.length}');
    buffer.writeln('');
    buffer.writeln('=' * 80);
    buffer.writeln('');
    
    for (final ticket in tickets) {
      buffer.writeln('ID: ${ticket['id']}');
      buffer.writeln('Título: ${ticket['title']}');
      buffer.writeln('Descripción: ${ticket['description']}');
      buffer.writeln('Estado: ${ticket['status']}');
      buffer.writeln('Prioridad: ${ticket['priority']}');
      buffer.writeln('Fecha de creación: ${ticket['created_at']}');
      if (ticket['due_date'] != null) {
        buffer.writeln('Fecha de vencimiento: ${ticket['due_date']}');
      }
      buffer.writeln('');
      buffer.writeln('-' * 80);
      buffer.writeln('');
    }
    
    final content = buffer.toString();
    final bytes = Uint8List.fromList(content.codeUnits);
    
    return await _saveFile(bytes, 'reporte_tickets_${now.millisecondsSinceEpoch}.txt', 'text/plain');
  }

  /// Exporta a Excel (XLSX) con tablas y fórmulas
  Future<String> _exportToExcel(
    List<Map<String, dynamic>> tickets,
    String? companyName,
  ) async {
    try {
      // Crear nuevo archivo Excel
      final excel = Excel.createExcel();
      
      // Eliminar la hoja por defecto si existe
      if (excel.sheets.keys.contains('Sheet1')) {
        excel.delete('Sheet1');
      }
      
      // Crear hoja de tickets
      final sheet = excel['Tickets'];
      
      final now = DateTime.now();
      
      // Encabezado (fila 0)
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('REPORTE DE TICKETS');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value = TextCellValue(companyName ?? 'Sistema de Tickets');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value = TextCellValue('Fecha: ${now.day}/${now.month}/${now.year}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).value = TextCellValue('Total: ${tickets.length}');
      
      // Encabezados de tabla (fila 5)
      final headers = ['ID', 'Titulo', 'Descripcion', 'Estado', 'Prioridad', 'Categoria ID', 'Asignado a ID', 'Creado por ID', 'Fecha Creacion', 'Fecha Vencimiento', 'Fecha Cierre'];
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 5));
        cell.value = TextCellValue(headers[i]);
        // Aplicar estilo solo si es posible
        try {
          cell.cellStyle = CellStyle(
            bold: true,
            backgroundColorHex: ExcelColor.fromHexString('CCCCCC'),
          );
        } catch (_) {
          // Si falla el estilo, continuar sin él
        }
      }
      
      // Datos (empezando en fila 6)
      for (int i = 0; i < tickets.length; i++) {
        final ticket = tickets[i];
        final row = i + 6;
        
        // Extraer y limpiar valores
        final id = _cleanValue(ticket['id']);
        final title = _cleanValue(ticket['title']);
        final description = _cleanValue(ticket['description']);
        final status = _cleanValue(ticket['status']);
        final priority = _cleanValue(ticket['priority']);
        final categoryId = _cleanValue(ticket['category_id']);
        final assignedToValue = ticket['assigned_to'];
        final assignedTo = assignedToValue != null ? _cleanValue(assignedToValue) : 'Sin asignar';
        final createdBy = _cleanValue(ticket['created_by']);
        final createdAt = _cleanValue(ticket['created_at']);
        final dueDate = _cleanValue(ticket['due_date']);
        final closedAt = _cleanValue(ticket['closed_at']);
        
        // Escribir valores en las celdas
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(id);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(title);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(description);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(status);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue(priority);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = TextCellValue(categoryId);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = TextCellValue(assignedTo);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value = TextCellValue(createdBy);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value = TextCellValue(createdAt);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row)).value = TextCellValue(dueDate);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row)).value = TextCellValue(closedAt);
      }
      
      // Crear hoja de estadísticas
      final statsSheet = excel['Estadisticas'];
      statsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('ESTADISTICAS');
      
      // Contar por estado
      final statusCounts = <String, int>{};
      final priorityCounts = <String, int>{};
      
      for (final ticket in tickets) {
        final statusValue = ticket['status'];
        final priorityValue = ticket['priority'];
        final status = statusValue != null ? _cleanValue(statusValue) : 'desconocido';
        final priority = priorityValue != null ? _cleanValue(priorityValue) : 'media';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        priorityCounts[priority] = (priorityCounts[priority] ?? 0) + 1;
      }
      
      statsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value = TextCellValue('Estado');
      statsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value = TextCellValue('Cantidad');
      int row = 3;
      statusCounts.forEach((status, count) {
        statsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(status);
        statsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = IntCellValue(count);
        row++;
      });
      
      statsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row + 1)).value = TextCellValue('Prioridad');
      statsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row + 1)).value = TextCellValue('Cantidad');
      row += 2;
      priorityCounts.forEach((priority, count) {
        statsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(priority);
        statsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = IntCellValue(count);
        row++;
      });
      
      // Codificar el archivo Excel
      final bytes = excel.encode();
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Error: No se pudo generar el archivo Excel');
      }
      
      // Convertir a Uint8List y guardar
      final fileBytes = Uint8List.fromList(bytes);
      
      return await _saveFile(
        fileBytes, 
        'reporte_tickets_${now.millisecondsSinceEpoch}.xlsx', 
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      );
    } catch (e) {
      throw Exception('Error al generar archivo Excel: $e');
    }
  }

  /// Limpia y convierte un valor a string seguro
  String _cleanValue(dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    // Limpiar caracteres problemáticos que pueden causar errores en Excel
    return str.replaceAll('\x00', '').trim();
  }

  /// Guarda el archivo y retorna la ruta
  /// Descarga automáticamente el archivo (sin compartir para evitar doble descarga)
  Future<String> _saveFile(Uint8List bytes, String fileName, String mimeType) async {
    if (kIsWeb) {
      // Para web, descargar automáticamente usando método nativo de HTML5
      // Crear blob y descargar automáticamente
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove(); // Remover el elemento después del click
      html.Url.revokeObjectUrl(url);
      
      return fileName;
    } else {
      // Para móvil/desktop, guardar en directorio de documentos
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      // El archivo ya está descargado/guardado automáticamente
      // No compartir automáticamente para evitar doble descarga
      // El usuario puede compartir manualmente si lo desea
      
      return file.path;
    }
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';

enum ExportFormat { pdf, word, excel, csv, json }

class ExportFormatDialog extends StatelessWidget {
  const ExportFormatDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Formato de Exportación'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormatOption(
            context,
            ExportFormat.pdf,
            'PDF',
            'Documento profesional con formato fijo',
            Icons.picture_as_pdf,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildFormatOption(
            context,
            ExportFormat.word,
            'Word (DOCX)',
            'Documento editable en Microsoft Word',
            Icons.description,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildFormatOption(
            context,
            ExportFormat.excel,
            'Excel (XLSX)',
            'Hoja de cálculo con tablas y fórmulas',
            Icons.table_chart,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildFormatOption(
            context,
            ExportFormat.csv,
            'CSV',
            'Archivo de texto separado por comas',
            Icons.table_rows,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildFormatOption(
            context,
            ExportFormat.json,
            'JSON',
            'Datos en formato JSON',
            Icons.code,
            Colors.purple,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Widget _buildFormatOption(
    BuildContext context,
    ExportFormat format,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(format),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  static Future<ExportFormat?> show(BuildContext context) {
    return showDialog<ExportFormat>(
      context: context,
      builder: (context) => const ExportFormatDialog(),
    );
  }
}


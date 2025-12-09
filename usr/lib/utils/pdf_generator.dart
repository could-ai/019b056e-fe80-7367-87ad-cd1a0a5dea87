import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/record_model.dart';
import '../services/translation_service.dart';

class PdfGenerator {
  static Future<void> generateAndPrint(
      List<BloodPressureRecord> records, String langCode) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(TranslationService.get('report_title', langCode),
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.PdfLogo(),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
                '${TranslationService.get('generated_on', langCode)}: ${dateFormatter.format(DateTime.now())}'),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.redAccent),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
              ),
              headers: [
                TranslationService.get('date', langCode),
                TranslationService.get('systolic_short', langCode),
                TranslationService.get('diastolic_short', langCode),
                TranslationService.get('pulse_short', langCode),
                TranslationService.get('notes', langCode),
              ],
              data: records.map((record) {
                return [
                  dateFormatter.format(record.date),
                  record.systolic.toString(),
                  record.diastolic.toString(),
                  record.pulse.toString(),
                  record.notes ?? '',
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'blood_pressure_report.pdf',
    );
  }
}

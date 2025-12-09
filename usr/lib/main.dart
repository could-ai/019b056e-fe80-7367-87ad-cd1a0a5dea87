import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const BloodPressureApp());
}

// --- Model ---
class BloodPressureRecord {
  final DateTime date;
  final int systolic;
  final int diastolic;
  final int pulse;

  BloodPressureRecord({
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
  });
}

// --- Localization ---
class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'es': {
      'appTitle': 'Control de Tensión Arterial',
      'date': 'Fecha',
      'systolic': 'Sistólica (mmHg)',
      'diastolic': 'Diastólica (mmHg)',
      'pulse': 'Pulso (BPM)',
      'addRecord': 'Agregar Registro',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'printPdf': 'Imprimir / Compartir PDF',
      'emptyList': 'No hay registros. Pulse + para agregar.',
      'language': 'Idioma',
      'sysShort': 'Sis',
      'diaShort': 'Dia',
      'pulShort': 'Pul',
      'errorInvalid': 'Por favor ingrese números válidos',
    },
    'de': {
      'appTitle': 'Blutdruckkontrolle',
      'date': 'Datum',
      'systolic': 'Systolisch (mmHg)',
      'diastolic': 'Diastolisch (mmHg)',
      'pulse': 'Puls (BPM)',
      'addRecord': 'Eintrag hinzufügen',
      'save': 'Speichern',
      'cancel': 'Abbrechen',
      'printPdf': 'Drucken / PDF teilen',
      'emptyList': 'Keine Einträge. Drücken Sie +, um hinzuzufügen.',
      'language': 'Sprache',
      'sysShort': 'Sys',
      'diaShort': 'Dia',
      'pulShort': 'Pul',
      'errorInvalid': 'Bitte geben Sie gültige Zahlen ein',
    },
  };

  static String get(String key, String langCode) {
    return _localizedValues[langCode]?[key] ?? key;
  }
}

class BloodPressureApp extends StatefulWidget {
  const BloodPressureApp({super.key});

  @override
  State<BloodPressureApp> createState() => _BloodPressureAppState();
}

class _BloodPressureAppState extends State<BloodPressureApp> {
  String _currentLang = 'es'; // Default to Spanish
  
  // Sample data
  final List<BloodPressureRecord> _records = [];

  void _toggleLanguage(String? newLang) {
    if (newLang != null) {
      setState(() {
        _currentLang = newLang;
      });
    }
  }

  void _addRecord(BloodPressureRecord record) {
    setState(() {
      _records.insert(0, record); // Add to top
    });
  }

  void _deleteRecord(int index) {
    setState(() {
      _records.removeAt(index);
    });
  }

  // --- PDF Generation ---
  Future<void> _printDoc() async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();
    
    // Headers based on current language
    final title = AppStrings.get('appTitle', _currentLang);
    final hDate = AppStrings.get('date', _currentLang);
    final hSys = AppStrings.get('systolic', _currentLang);
    final hDia = AppStrings.get('diastolic', _currentLang);
    final hPul = AppStrings.get('pulse', _currentLang);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(title, style: pw.TextStyle(font: font, fontSize: 24)),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: font),
                headers: [hDate, hSys, hDia, hPul],
                data: _records.map((r) => [
                  DateFormat('yyyy-MM-dd HH:mm').format(r.date),
                  r.systolic.toString(),
                  r.diastolic.toString(),
                  r.pulse.toString(),
                ]).toList(),
              ),
              pw.Footer(
                leading: pw.Text(DateFormat('yyyy-MM-dd').format(DateTime.now())),
                trailing: pw.Text('Page ${context.pageNumber}'),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'blood_pressure_report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Pressure App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => _buildHomePage(context),
      },
    );
  }

  Widget _buildHomePage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('appTitle', _currentLang)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Language Switcher
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentLang,
              icon: const Icon(Icons.language),
              items: const [
                DropdownMenuItem(value: 'es', child: Text('Español 🇪🇸')),
                DropdownMenuItem(value: 'de', child: Text('Deutsch 🇩🇪')),
              ],
              onChanged: _toggleLanguage,
            ),
          ),
          const SizedBox(width: 10),
          // Print Button
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: AppStrings.get('printPdf', _currentLang),
            onPressed: _records.isNotEmpty ? _printDoc : null,
          ),
        ],
      ),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.get('emptyList', _currentLang),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return Dismissible(
                  key: ValueKey(record),
                  background: Container(color: Colors.red),
                  onDismissed: (_) => _deleteRecord(index),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getBpColor(record.systolic, record.diastolic),
                        child: const Icon(Icons.favorite, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(record.date),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${AppStrings.get('sysShort', _currentLang)}: ${record.systolic}'),
                          Text('${AppStrings.get('diaShort', _currentLang)}: ${record.diastolic}'),
                          Text('${AppStrings.get('pulShort', _currentLang)}: ${record.pulse}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getBpColor(int sys, int dia) {
    // Simple color coding logic
    if (sys > 140 || dia > 90) return Colors.red;
    if (sys > 120 || dia > 80) return Colors.orange;
    return Colors.green;
  }

  void _showAddDialog(BuildContext context) {
    final sysController = TextEditingController();
    final diaController = TextEditingController();
    final pulController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('addRecord', _currentLang)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNumberField(sysController, AppStrings.get('systolic', _currentLang)),
                _buildNumberField(diaController, AppStrings.get('diastolic', _currentLang)),
                _buildNumberField(pulController, AppStrings.get('pulse', _currentLang)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get('cancel', _currentLang)),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final sys = int.tryParse(sysController.text);
                final dia = int.tryParse(diaController.text);
                final pul = int.tryParse(pulController.text);

                if (sys != null && dia != null && pul != null) {
                  _addRecord(BloodPressureRecord(
                    date: DateTime.now(),
                    systolic: sys,
                    diastolic: dia,
                    pulse: pul,
                  ));
                  Navigator.pop(ctx);
                }
              }
            },
            child: Text(AppStrings.get('save', _currentLang)),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty || int.tryParse(value) == null) {
            return AppStrings.get('errorInvalid', _currentLang);
          }
          return null;
        },
      ),
    );
  }
}

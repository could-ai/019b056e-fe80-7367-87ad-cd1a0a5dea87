import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/record_model.dart';
import '../services/translation_service.dart';
import '../utils/pdf_generator.dart';

class HomeScreen extends StatefulWidget {
  final Function(String) onLanguageChanged;
  final String currentLanguage;

  const HomeScreen({
    super.key,
    required this.onLanguageChanged,
    required this.currentLanguage,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // In-memory list for demo purposes. In a real app, this would come from a database.
  final List<BloodPressureRecord> _records = [];

  void _addRecord(BloodPressureRecord record) {
    setState(() {
      _records.insert(0, record); // Add to top
    });
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddRecordSheet(
        langCode: widget.currentLanguage,
        onSave: _addRecord,
      ),
    );
  }

  Color _getBpColor(int systolic, int diastolic) {
    if (systolic > 140 || diastolic > 90) return Colors.red.shade100;
    if (systolic < 90 || diastolic < 60) return Colors.blue.shade100;
    return Colors.green.shade100;
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => TranslationService.get(key, widget.currentLanguage);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('app_title')),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: t('print'),
            onPressed: () {
              if (_records.isNotEmpty) {
                PdfGenerator.generateAndPrint(_records, widget.currentLanguage);
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: widget.onLanguageChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'es', child: Text('Español')),
              const PopupMenuItem(value: 'de', child: Text('Deutsch')),
            ],
          ),
        ],
      ),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(t('empty_list'), style: const TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _records.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final record = _records[index];
                return Card(
                  color: _getBpColor(record.systolic, record.diastolic),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.favorite, color: Colors.red),
                    ),
                    title: Text(
                      '${record.systolic} / ${record.diastolic} mmHg',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${t('pulse')}: ${record.pulse} bpm'),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(record.date),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        if (record.notes != null && record.notes!.isNotEmpty)
                          Text('${t('notes')}: ${record.notes}'),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(t('new_record'), style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class AddRecordSheet extends StatefulWidget {
  final String langCode;
  final Function(BloodPressureRecord) onSave;

  const AddRecordSheet({super.key, required this.langCode, required this.onSave});

  @override
  State<AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<AddRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _sysController = TextEditingController();
  final _diaController = TextEditingController();
  final _pulseController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    String t(String key) => TranslationService.get(key, widget.langCode);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t('new_record'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sysController,
                    decoration: InputDecoration(
                      labelText: t('systolic'),
                      border: const OutlineInputBorder(),
                      suffixText: 'mmHg',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _diaController,
                    decoration: InputDecoration(
                      labelText: t('diastolic'),
                      border: const OutlineInputBorder(),
                      suffixText: 'mmHg',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pulseController,
              decoration: InputDecoration(
                labelText: t('pulse'),
                border: const OutlineInputBorder(),
                suffixText: 'bpm',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: t('notes'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t('cancel')),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final record = BloodPressureRecord(
                        id: DateTime.now().toString(),
                        date: DateTime.now(),
                        systolic: int.parse(_sysController.text),
                        diastolic: int.parse(_diaController.text),
                        pulse: int.parse(_pulseController.text),
                        notes: _notesController.text,
                      );
                      widget.onSave(record);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(t('save')),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

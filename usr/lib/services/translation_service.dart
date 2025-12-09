import 'package:flutter/material.dart';

class TranslationService {
  static final Map<String, Map<String, String>> _localizedValues = {
    'es': {
      'app_title': 'Control de Tensión',
      'history': 'Historial',
      'new_record': 'Nueva Medición',
      'date': 'Fecha',
      'systolic': 'Sistólica (Alta)',
      'diastolic': 'Diastólica (Baja)',
      'pulse': 'Pulso',
      'notes': 'Notas',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'share_pdf': 'Compartir PDF',
      'print': 'Imprimir',
      'language': 'Idioma / Sprache',
      'empty_list': 'No hay mediciones registradas.',
      'error_invalid': 'Por favor ingrese valores válidos',
      'report_title': 'Reporte de Tensión Arterial',
      'generated_on': 'Generado el',
      'systolic_short': 'SIS',
      'diastolic_short': 'DIA',
      'pulse_short': 'PUL',
    },
    'de': {
      'app_title': 'Blutdruckkontrolle',
      'history': 'Verlauf',
      'new_record': 'Neue Messung',
      'date': 'Datum',
      'systolic': 'Systolisch (Hoch)',
      'diastolic': 'Diastolisch (Niedrig)',
      'pulse': 'Puls',
      'notes': 'Notizen',
      'save': 'Speichern',
      'cancel': 'Abbrechen',
      'share_pdf': 'PDF Teilen',
      'print': 'Drucken',
      'language': 'Idioma / Sprache',
      'empty_list': 'Keine Messungen aufgezeichnet.',
      'error_invalid': 'Bitte gültige Werte eingeben',
      'report_title': 'Blutdruckbericht',
      'generated_on': 'Erstellt am',
      'systolic_short': 'SYS',
      'diastolic_short': 'DIA',
      'pulse_short': 'PULS',
    },
  };

  static String get(String key, String languageCode) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
}

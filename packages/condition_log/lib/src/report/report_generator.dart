import 'dart:io';
import 'dart:typed_data';

import 'package:condition_log/src/database.dart';
import 'package:condition_log/src/report/report_config.dart';
import 'package:condition_log/src/repository.dart';
import 'package:csv/csv.dart' as csv_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportGenerator {
  ReportGenerator({required this.repo, required this.config});

  final ConditionLogRepo repo;
  final ReportConfig config;

  /// Loads all data for [pet] between [from] and [to].
  Future<ReportData> loadData({
    required Pet pet,
    required DateTime from,
    required DateTime to,
  }) async {
    final events = await repo.eventsBetween(pet.id, from: from, to: to);
    final measurements = await repo.measurementsBetween(
      pet.id,
      from: from,
      to: to,
    );
    final medications = await repo.watchMedications(pet.id).first;
    final doses = await repo.dosesBetween(petId: pet.id, from: from, to: to);
    return ReportData(
      pet: pet,
      from: from,
      to: to,
      events: events,
      measurements: measurements,
      medications: medications,
      doses: doses,
    );
  }

  // ---- CSV ---------------------------------------------------------

  /// One CSV per section, joined with a blank line, in ReportConfig order.
  String buildCsv(ReportData data) {
    final buffer = StringBuffer();
    for (final section in config.sections) {
      _appendSectionCsv(buffer, section, data);
      buffer.writeln();
    }
    return buffer.toString();
  }

  void _appendSectionCsv(
    StringBuffer buffer,
    ReportSection section,
    ReportData data,
  ) {
    final rows = switch (section) {
      ReportSection.petSummary => _petSummaryRows(data),
      ReportSection.eventsTable => _eventsRows(data),
      ReportSection.measurementsTable => _measurementsRows(data),
      ReportSection.doseAdherence => _doseAdherenceRows(data),
      ReportSection.medicationsList => _medicationsRows(data),
      ReportSection.notes => const [
          ['Notes'],
          ['(Notes are excluded from CSV; see PDF.)'],
        ],
    };
    buffer.write(csv_pkg.csv.encode(rows));
    buffer.writeln();
  }

  List<List<dynamic>> _petSummaryRows(ReportData data) => [
        ['Pet summary'],
        ['Name', data.pet.name],
        ['Species', data.pet.species],
        if (data.pet.breed != null) ['Breed', data.pet.breed],
        if (data.pet.weightKg != null) ['Weight (kg)', data.pet.weightKg],
        ['Period', '${_isoDate(data.from)} to ${_isoDate(data.to)}'],
        [config.disclaimer],
      ];

  List<List<dynamic>> _eventsRows(ReportData data) {
    final rows = <List<dynamic>>[
      ['Events'],
      ['When', 'Kind', 'Subtype', 'Duration (s)', 'Triggers', 'Note'],
    ];
    for (final e in data.events) {
      rows.add([
        _isoDateTime(e.startedAt),
        config.labelForEventKind(e.kind),
        e.subtype ?? '',
        e.durationSec ?? '',
        e.triggers ?? '',
        e.note ?? '',
      ]);
    }
    if (data.events.isEmpty) rows.add(['(No events in period)']);
    return rows;
  }

  List<List<dynamic>> _measurementsRows(ReportData data) {
    final rows = <List<dynamic>>[
      ['Measurements'],
      ['When', 'Kind', 'Value', 'Unit', 'Label'],
    ];
    for (final m in data.measurements) {
      rows.add([
        _isoDateTime(m.takenAt),
        config.labelForMeasurementKind(m.kind),
        m.value,
        m.unit,
        m.label ?? '',
      ]);
    }
    if (data.measurements.isEmpty) {
      rows.add(['(No measurements in period)']);
    }
    return rows;
  }

  List<List<dynamic>> _doseAdherenceRows(ReportData data) {
    final scheduled = data.doses.length;
    final taken = data.doses.where((d) => d.takenAt != null && !d.skipped).length;
    final skipped = data.doses.where((d) => d.skipped).length;
    final pct = scheduled == 0
        ? ''
        : '${((taken / scheduled) * 100).toStringAsFixed(0)}%';
    return [
      ['Dose adherence'],
      ['Scheduled', scheduled],
      ['Taken', taken],
      ['Skipped', skipped],
      ['Adherence', pct],
    ];
  }

  List<List<dynamic>> _medicationsRows(ReportData data) {
    final rows = <List<dynamic>>[
      ['Medications'],
      ['Name', 'Strength (mg)', 'Dose', 'Times per day'],
    ];
    for (final m in data.medications) {
      rows.add([
        m.name,
        m.strengthMg ?? '',
        m.doseText ?? '',
        m.timesPerDay ?? '',
      ]);
    }
    if (data.medications.isEmpty) {
      rows.add(['(No active medications)']);
    }
    return rows;
  }

  // ---- PDF ---------------------------------------------------------

  Future<Uint8List> buildPdfBytes(ReportData data) {
    final doc = pw.Document(
      title: '${config.appName} — ${data.pet.name}',
      author: config.appName,
    );

    doc.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              '${config.appName} · ${data.pet.name}',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            'Report period: ${_isoDate(data.from)} — ${_isoDate(data.to)}',
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 11),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            config.disclaimer,
            style: pw.TextStyle(
              color: PdfColors.grey700,
              fontStyle: pw.FontStyle.italic,
              fontSize: 10,
            ),
          ),
          pw.SizedBox(height: 12),
          for (final section in config.sections) ...[
            _sectionPdf(section, data),
            pw.SizedBox(height: 12),
          ],
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _sectionPdf(ReportSection section, ReportData data) {
    return switch (section) {
      ReportSection.petSummary => _petSummaryPdf(data),
      ReportSection.eventsTable => _tablePdf('Events', _eventsRows(data)),
      ReportSection.measurementsTable =>
        _tablePdf('Measurements', _measurementsRows(data)),
      ReportSection.doseAdherence =>
        _tablePdf('Dose adherence', _doseAdherenceRows(data)),
      ReportSection.medicationsList =>
        _tablePdf('Medications', _medicationsRows(data)),
      ReportSection.notes => pw.Text(
          'Notes section not included in this build.',
          style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
        ),
    };
  }

  pw.Widget _petSummaryPdf(ReportData data) {
    final entries = <List<String>>[
      ['Name', data.pet.name],
      ['Species', data.pet.species],
      if (data.pet.breed != null) ['Breed', data.pet.breed!],
      if (data.pet.weightKg != null)
        ['Weight', '${data.pet.weightKg!.toStringAsFixed(1)} kg'],
    ];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Pet',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.TableHelper.fromTextArray(
          data: entries,
          headers: null,
          border: null,
          cellStyle: const pw.TextStyle(fontSize: 11),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    );
  }

  pw.Widget _tablePdf(String title, List<List<dynamic>> rows) {
    if (rows.isEmpty || rows.length == 1) {
      return pw.Text(title,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold));
    }
    final headerRow = rows.length > 1 ? rows[1] : null;
    final bodyRows = rows.length > 2 ? rows.sublist(2) : const <List<dynamic>>[];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.TableHelper.fromTextArray(
          headers: headerRow?.map((c) => c.toString()).toList(),
          data: bodyRows.map((r) => r.map((c) => c.toString()).toList()).toList(),
          cellStyle: const pw.TextStyle(fontSize: 10),
          headerStyle: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        ),
      ],
    );
  }

  // ---- Save to disk -----------------------------------------------

  Future<File> saveCsv(ReportData data, {String? filename}) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = filename ??
        'report_${data.pet.name.replaceAll(RegExp("[^A-Za-z0-9]"), "_")}_${_isoDate(data.to)}.csv';
    final file = File('${dir.path}/$name');
    await file.writeAsString(buildCsv(data));
    return file;
  }

  Future<File> savePdf(ReportData data, {String? filename}) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = filename ??
        'report_${data.pet.name.replaceAll(RegExp("[^A-Za-z0-9]"), "_")}_${_isoDate(data.to)}.pdf';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(await buildPdfBytes(data));
    return file;
  }

  String _isoDate(DateTime d) {
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  String _isoDateTime(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${_isoDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

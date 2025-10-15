import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/rendering.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edurise/features/tests/domain/models/answer_sheet_template.dart';
import 'package:edurise/features/tests/data/repositories/answer_sheet_repository.dart';

class ZipgradeSheetPage extends StatefulWidget {
  const ZipgradeSheetPage({super.key});

  @override
  State<ZipgradeSheetPage> createState() => _ZipgradeSheetPageState();
}

class _ZipgradeSheetPageState extends State<ZipgradeSheetPage> {
  int _numQuestions = 50;
  int _numOptions = 5;
  final GlobalKey _previewKey = GlobalKey();
  late String _barcodeData;
  final _repository = AnswerSheetRepository();

  @override
  void initState() {
    super.initState();
    _barcodeData = const Uuid().v4();
  }

  Future<void> _exportPng() async {
    final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final bytes = byteData.buffer.asUint8List();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/zipgrade_sheet.png');
    await file.writeAsBytes(bytes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PNG сохранён в документы')));
  }

  Future<void> _previewPdf() async {
    try {
      // Сохранить шаблон в Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final template = AnswerSheetTemplate(
          id: _barcodeData,
          barcodeData: _barcodeData,
          numQuestions: _numQuestions,
          numOptions: _numOptions,
          createdAt: DateTime.now(),
          createdBy: user.uid,
        );
        await _repository.saveTemplate(template);
      }

      if (!mounted) return;
      
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _PdfPreviewPage(
            numQuestions: _numQuestions,
            numOptions: _numOptions,
            barcodeData: _barcodeData,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _exportPdf() async {
    try {
      // Сохранить шаблон в Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final template = AnswerSheetTemplate(
          id: _barcodeData,
          barcodeData: _barcodeData,
          numQuestions: _numQuestions,
          numOptions: _numOptions,
          createdAt: DateTime.now(),
          createdBy: user.uid,
        );
        await _repository.saveTemplate(template);
      }

      final doc = pw.Document();
      
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (context) => _buildPdfContent(),
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF создан и шаблон сохранён')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  pw.Widget _buildPdfContent() {
    return pw.Center(
      child: pw.SizedBox(
        width: 500,
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            // Header with registration marks
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildRegistrationMark(),
                pw.Expanded(child: _buildPdfHeader()),
                _buildRegistrationMark(),
              ],
            ),
            pw.SizedBox(height: 16),
            // Student ID row
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 24),
              child: pw.Row(
                children: [
                  pw.Text('Student ZipGrade ID', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),
            pw.SizedBox(height: 8),
            // Main content with key version and questions
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildRegistrationMark(),
                pw.SizedBox(width: 8),
                _buildPdfKeyVersion(),
                pw.SizedBox(width: 12),
                pw.Expanded(child: _buildPdfQuestions()),
                pw.SizedBox(width: 8),
                _buildRegistrationMark(),
              ],
            ),
            pw.SizedBox(height: 20),
            // Footer
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildRegistrationMark(),
                pw.Text('ZIPGRADE.COM', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                _buildRegistrationMark(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildRegistrationMark() {
    return pw.Container(
      width: 16,
      height: 16,
      color: PdfColors.black,
    );
  }

  pw.Widget _buildPdfHeader() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(horizontal: 16),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(right: pw.BorderSide(width: 1)),
                  ),
                  child: pw.Text('Name', style: const pw.TextStyle(fontSize: 10)),
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Date', style: const pw.TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
          pw.Container(
            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 1))),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(right: pw.BorderSide(width: 1)),
                    ),
                    child: pw.Text('Class', style: const pw.TextStyle(fontSize: 10)),
                  ),
                ),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Quiz', style: const pw.TextStyle(fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfKeyVersion() {
    final letters = ['A', 'B', 'C', 'D', 'E'].take(_numOptions).toList();
    return pw.Column(
      children: [
        pw.Text('Key', style: const pw.TextStyle(fontSize: 8)),
        pw.Text('Version', style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(height: 4),
        for (var letter in letters)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Container(
              width: 16,
              height: 16,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                border: pw.Border.all(width: 1),
              ),
              child: pw.Text(letter, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  pw.Widget _buildPdfQuestions() {
    final columns = _numQuestions <= 10 ? 1 : _numQuestions <= 20 ? 2 : 3;
    final questionsPerColumn = (_numQuestions / columns).ceil();
    final letters = ['A', 'B', 'C', 'D', 'E'].take(_numOptions).toList();
    
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: List.generate(columns, (colIndex) {
        final startQ = colIndex * questionsPerColumn + 1;
        final endQ = ((colIndex + 1) * questionsPerColumn).clamp(0, _numQuestions);
        
        return pw.Expanded(
          child: pw.Column(
            children: [
              // Header row (empty for alignment)
              pw.Row(
                children: [
                  if (colIndex > 0) _buildSmallRegistrationMark(),
                  if (colIndex > 0) pw.SizedBox(width: 4),
                  pw.SizedBox(width: 20),
                  for (int i = 0; i < _numOptions; i++) ...[
                    pw.SizedBox(width: 14),
                    if (i < _numOptions - 1) pw.SizedBox(width: 10),
                  ],
                ],
              ),
              pw.SizedBox(height: 4),
              // Questions
              for (int q = startQ; q <= endQ; q++)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    children: [
                      if (colIndex > 0) pw.SizedBox(width: 20),
                      pw.Container(
                        width: 16,
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text('$q', style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.SizedBox(width: 4),
                      for (int i = 0; i < _numOptions; i++) ...[
                        pw.Container(
                          width: 14,
                          height: 14,
                          alignment: pw.Alignment.center,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            border: pw.Border.all(width: 0.5, color: PdfColors.grey600),
                          ),
                          child: pw.Text(
                            letters[i], 
                            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        if (i < _numOptions - 1) pw.SizedBox(width: 10),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  pw.Widget _buildSmallRegistrationMark() {
    return pw.Container(
      width: 12,
      height: 12,
      color: PdfColors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ZipGrade Бланк', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: appPrimary,
        elevation: 0,
      ),
      backgroundColor: appBackground,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Количество вопросов:'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _numQuestions,
                    items: [10, 20, 30, 40, 50]
                        .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: (v) => setState(() => _numQuestions = v ?? 50),
                  ),
                  const SizedBox(width: 24),
                  const Text('Вариантов ответа:'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _numOptions,
                    items: [4, 5]
                        .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: (v) => setState(() => _numOptions = v ?? 5),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton.icon(
                  onPressed: _previewPdf,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Просмотр'),
                  style: ElevatedButton.styleFrom(backgroundColor: appPrimary),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                  onPressed: _exportPng,
                  icon: const Icon(Icons.image),
                  label: const Text('PNG'),
                  style: ElevatedButton.styleFrom(backgroundColor: appAccentEnd),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _exportPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF'),
                  style: ElevatedButton.styleFrom(backgroundColor: appAccentEnd),
                ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: RepaintBoundary(
                  key: _previewKey,
                  child: _SheetPreview(
                    numQuestions: _numQuestions, 
                    numOptions: _numOptions, 
                    barcodeData: _barcodeData,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetPreview extends StatelessWidget {
  final int numQuestions;
  final int numOptions;
  final String barcodeData;
  const _SheetPreview({required this.numQuestions, required this.numOptions, required this.barcodeData});

  Widget _buildRegistrationMark() {
    return Container(
      width: 20,
      height: 20,
      color: Colors.black,
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(width: 2.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(width: 1.5)),
                  ),
                  child: Text('Name', style: GoogleFonts.montserrat(fontSize: 12)),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: Text('Date', style: GoogleFonts.montserrat(fontSize: 12)),
                ),
              ),
            ],
          ),
          Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(width: 1.5))),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1.5)),
                    ),
                    child: Text('Class', style: GoogleFonts.montserrat(fontSize: 12)),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Text('Quiz', style: GoogleFonts.montserrat(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyVersion() {
    final letters = ['A', 'B', 'C', 'D', 'E'].take(numOptions).toList();
    return Column(
      children: [
        Text('Key', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w500)),
        Text('Version', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        for (var letter in letters)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1.5),
              ),
              child: Text(letter, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }



  Widget _buildQuestions() {
    final columns = numQuestions <= 10 ? 1 : numQuestions <= 20 ? 2 : 3;
    final questionsPerColumn = (numQuestions / columns).ceil();
    final letters = ['A', 'B', 'C', 'D', 'E'].take(numOptions).toList();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(columns, (colIndex) {
        final startQ = colIndex * questionsPerColumn + 1;
        final endQ = ((colIndex + 1) * questionsPerColumn).clamp(0, numQuestions);
        
        return Expanded(
          child: Column(
            children: [
              // Header row (empty for alignment)
              Row(
                children: [
                  if (colIndex > 0) Container(width: 16, height: 16, color: Colors.black),
                  if (colIndex > 0) const SizedBox(width: 6),
                  const SizedBox(width: 26),
                  for (int i = 0; i < numOptions; i++)
                    const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 6),
              // Questions
              for (int q = startQ; q <= endQ; q++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      if (colIndex > 0) const SizedBox(width: 22),
                      Container(
                        width: 20,
                        alignment: Alignment.centerRight,
                        child: Text('$q', style: GoogleFonts.montserrat(fontSize: 11)),
                      ),
                      const SizedBox(width: 6),
                      for (int i = 0; i < numOptions; i++)
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Container(
                              width: 18,
                              height: 18,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(width: 1, color: Colors.grey.shade600),
                              ),
                              child: Text(
                                letters[i], 
                                style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with registration marks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRegistrationMark(),
              Expanded(child: _buildHeader()),
              _buildRegistrationMark(),
            ],
          ),
          const SizedBox(height: 20),
          // Student ID label
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Student ZipGrade ID', style: GoogleFonts.montserrat(fontSize: 11)),
            ),
          ),
          const SizedBox(height: 12),
          // Main content with key version and questions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRegistrationMark(),
              const SizedBox(width: 12),
              _buildKeyVersion(),
              const SizedBox(width: 16),
              Expanded(child: _buildQuestions()),
              const SizedBox(width: 12),
              _buildRegistrationMark(),
            ],
          ),
          const SizedBox(height: 30),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRegistrationMark(),
              Text('ZIPGRADE.COM', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
              _buildRegistrationMark(),
            ],
          ),
        ],
      ),
    );
  }
}

class _PdfPreviewPage extends StatelessWidget {
  final int numQuestions;
  final int numOptions;
  final String barcodeData;

  const _PdfPreviewPage({
    required this.numQuestions,
    required this.numOptions,
    required this.barcodeData,
  });

  pw.Widget _buildPdfContent() {
    return pw.Center(
      child: pw.SizedBox(
        width: 500,
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildRegistrationMark(),
                pw.Expanded(child: _buildPdfHeader()),
                _buildRegistrationMark(),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 24),
              child: pw.Row(
                children: [
                  pw.Text('Student ZipGrade ID', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildRegistrationMark(),
                pw.SizedBox(width: 8),
                _buildPdfKeyVersion(),
                pw.SizedBox(width: 12),
                pw.Expanded(child: _buildPdfQuestions()),
                pw.SizedBox(width: 8),
                _buildRegistrationMark(),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildRegistrationMark(),
                pw.Text('ZIPGRADE.COM', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                _buildRegistrationMark(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildRegistrationMark() {
    return pw.Container(width: 16, height: 16, color: PdfColors.black);
  }

  pw.Widget _buildPdfHeader() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(horizontal: 16),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(width: 1))),
                  child: pw.Text('Name', style: const pw.TextStyle(fontSize: 10)),
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Date', style: const pw.TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
          pw.Container(
            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 1))),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(width: 1))),
                    child: pw.Text('Class', style: const pw.TextStyle(fontSize: 10)),
                  ),
                ),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Quiz', style: const pw.TextStyle(fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfKeyVersion() {
    final letters = ['A', 'B', 'C', 'D', 'E'].take(numOptions).toList();
    return pw.Column(
      children: [
        pw.Text('Key', style: const pw.TextStyle(fontSize: 8)),
        pw.Text('Version', style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(height: 4),
        for (var letter in letters)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Container(
              width: 16, height: 16, alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(width: 1)),
              child: pw.Text(letter, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  pw.Widget _buildPdfQuestions() {
    final columns = numQuestions <= 10 ? 1 : numQuestions <= 20 ? 2 : 3;
    final questionsPerColumn = (numQuestions / columns).ceil();
    final letters = ['A', 'B', 'C', 'D', 'E'].take(numOptions).toList();
    
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: List.generate(columns, (colIndex) {
        final startQ = colIndex * questionsPerColumn + 1;
        final endQ = ((colIndex + 1) * questionsPerColumn).clamp(0, numQuestions);
        
        return pw.Expanded(
          child: pw.Column(
            children: [
              pw.Row(
                children: [
                  if (colIndex > 0) _buildSmallMark(),
                  if (colIndex > 0) pw.SizedBox(width: 4),
                  pw.SizedBox(width: 20),
                  for (int i = 0; i < numOptions; i++) ...[
                    pw.SizedBox(width: 14),
                    if (i < numOptions - 1) pw.SizedBox(width: 10),
                  ],
                ],
              ),
              pw.SizedBox(height: 4),
              for (int q = startQ; q <= endQ; q++)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    children: [
                      if (colIndex > 0) pw.SizedBox(width: 20),
                      pw.Container(width: 16, alignment: pw.Alignment.centerRight,
                        child: pw.Text('$q', style: const pw.TextStyle(fontSize: 9))),
                      pw.SizedBox(width: 4),
                      for (int i = 0; i < numOptions; i++) ...[
                        pw.Container(
                          width: 14, height: 14, alignment: pw.Alignment.center,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            border: pw.Border.all(width: 0.5, color: PdfColors.grey600),
                          ),
                          child: pw.Text(letters[i], 
                            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                        ),
                        if (i < numOptions - 1) pw.SizedBox(width: 5),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  pw.Widget _buildSmallMark() => pw.Container(width: 12, height: 12, color: PdfColors.black);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Просмотр PDF', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: appPrimary,
        elevation: 0,
      ),
      body: PdfPreview(
        build: (format) async {
          final doc = pw.Document();
          doc.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(30),
              build: (context) => _buildPdfContent(),
            ),
          );
          return doc.save();
        },
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

/// Utility to generate nicely formatted PDFs with Cyrillic support (if font in assets).

/// Result of PDF generation.
/// `path` — saved file path. `fontFound` — true if an embedded font supporting
/// Cyrillic was found in assets/fonts/.
class PdfResult {
  final String path;
  final bool fontFound;
  PdfResult(this.path, this.fontFound);

  String? get generatedTitle => null;
}

class PdfGenerator {
  /// Parses inline markdown (bold, italic, code) and returns formatted text
  static String _parseInlineMarkdown(String text, pw.Font mainFont, pw.Font? boldFont, pw.Font monoFont) {
    // For now, we'll just strip markdown symbols and return plain text
    // The pdf package has limited support for rich text styling in a single TextSpan
    // A full implementation would use pw.RichText with pw.TextSpan children
    
    // Strip markdown formatting for simplicity
    var result = text;
    result = result.replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1'); // bold
    result = result.replaceAll(RegExp(r'\*(.+?)\*'), r'$1'); // italic
    result = result.replaceAll(RegExp(r'__(.+?)__'), r'$1'); // bold
    result = result.replaceAll(RegExp(r'_(.+?)_'), r'$1'); // italic
    result = result.replaceAll(RegExp(r'`(.+?)`'), r'$1'); // inline code
    return result;
  }

  static Future<PdfResult> generatePlanPdf({
    required String title,
    required String content,
    String? author,
    String? fileName, required Future<String> Function(dynamic prompt) aiGenerate,
  }) async {
    final doc = pw.Document();

    // Load main font (try several common filenames in assets/fonts)
    pw.Font mainFont;
    final fontCandidates = [
      'assets/fonts/NotoSans-Regular.ttf',
      'assets/fonts/Roboto-Regular.ttf',
      'assets/fonts/DejaVuSans.ttf',
    ];
  ByteData? loadedFontData;
  var fontFound = false;
    for (final p in fontCandidates) {
      try {
        final data = await rootBundle.load(p);
        if (data.lengthInBytes > 0) {
          loadedFontData = data;
          fontFound = true;
          print('[ai_chat] Found font asset: $p (${data.lengthInBytes} bytes)');
          break;
        }
      } catch (_) {
        // continue
      }
    }
  if (loadedFontData != null) {
      try {
        mainFont = pw.Font.ttf(loadedFontData);
      } catch (e) {
        print('[ai_chat] Error creating pw.Font from ByteData: $e');
        mainFont = pw.Font.helvetica();
      }
    } else {
      print('[ai_chat] Warning: no embedded font found in assets/fonts/ - using fallback (may lack Cyrillic glyphs)');
      mainFont = pw.Font.helvetica();
    }

    // Optional monospace for code blocks
    pw.Font monoFont;
    try {
  final monoData = await rootBundle.load('assets/fonts/DejaVuSansMono.ttf');
  monoFont = pw.Font.ttf(monoData);
    } catch (_) {
      monoFont = pw.Font.courier();
    }

    final base = pw.TextStyle(font: mainFont, fontSize: 12, height: 1.3);
    final h1 = pw.TextStyle(font:  mainFont, fontSize: 20, fontWeight: pw.FontWeight.bold);
    final h2 = pw.TextStyle(font:  mainFont, fontSize: 16, fontWeight: pw.FontWeight.bold);
    final codeStyle = pw.TextStyle(font: monoFont, fontSize: 10);

    // Content pages (title included inside MultiPage so everything is flowable)
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData(defaultTextStyle: base),
      header: (ctx) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(title, style: pw.TextStyle(font: mainFont, fontSize: 9, color: PdfColors.grey600)),
      ),
      footer: (ctx) => pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text('Страница ${ctx.pageNumber} / ${ctx.pagesCount}', style: pw.TextStyle(font: mainFont, fontSize: 9, color: PdfColors.grey600)),
      ),
      build: (ctx) {
        final widgets = <pw.Widget>[];

        // Title block at the top of the document (flowable)
        widgets.add(pw.SizedBox(height: 24));
        widgets.add(pw.Center(child: pw.Text(title, style: h1, textAlign: pw.TextAlign.center)));
        if (author != null) {
          widgets.add(pw.SizedBox(height: 8));
          widgets.add(pw.Center(child: pw.Text(author, style: base)));
        }
        widgets.add(pw.SizedBox(height: 18));
        widgets.add(pw.Center(child: pw.Text('План-конспект', style: h2)));
        widgets.add(pw.SizedBox(height: 20));

        // Parse markdown-like content with support for headings, bold, code blocks, bullets
        final lines = content.replaceAll('\r\n', '\n').split('\n');
        var inCode = false;
        final codeBuf = StringBuffer();

        for (var raw in lines) {
          final line = raw.trimRight();
          if (line.startsWith('```')) {
            if (!inCode) {
              inCode = true;
              codeBuf.clear();
            } else {
              inCode = false;
              widgets.add(pw.SizedBox(height: 6));
              widgets.add(pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(codeBuf.toString(), style: codeStyle),
              ));
              widgets.add(pw.SizedBox(height: 8));
            }
            continue;
          }
          if (inCode) {
            codeBuf.writeln(line);
            continue;
          }

          // Headings
          if (line.startsWith('### ')) {
            widgets.add(pw.SizedBox(height: 6));
            widgets.add(pw.Text(line.substring(4).trim(), style: h2));
            continue;
          }
          if (line.startsWith('## ')) {
            widgets.add(pw.SizedBox(height: 8));
            widgets.add(pw.Text(line.substring(3).trim(), style: h1));
            continue;
          }
          if (line.startsWith('# ')) {
            widgets.add(pw.SizedBox(height: 10));
            widgets.add(pw.Text(line.substring(2).trim(), style: pw.TextStyle(font: mainFont, fontSize: 24, fontWeight: pw.FontWeight.bold)));
            continue;
          }

          // Bullets
          if (line.startsWith('- ') || line.startsWith('* ')) {
            final bulletText = line.substring(2).trim();
            widgets.add(pw.Bullet(text: _parseInlineMarkdown(bulletText, mainFont, monoFont, monoFont), style: base));
            continue;
          }
          
          // Numbered lists
          final numMatch = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(line);
          if (numMatch != null) {
            final num = numMatch.group(1)!;
            final text = numMatch.group(2)!;
            widgets.add(pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(width: 20, child: pw.Text('$num.', style: base)),
                pw.Expanded(child: pw.Text(_parseInlineMarkdown(text, mainFont, monoFont, monoFont), style: base)),
              ],
            ));
            continue;
          }

          if (line.isEmpty) {
            widgets.add(pw.SizedBox(height: 6));
            continue;
          }
          
          // Regular paragraph with inline markdown
          widgets.add(pw.Paragraph(text: _parseInlineMarkdown(line, mainFont, monoFont, monoFont), style: base));
        }

        return widgets;
      },
    ));

  final outDir = await getTemporaryDirectory();
  final name = fileName ?? 'plan_${DateTime.now().millisecondsSinceEpoch}.pdf';
  final file = File('${outDir.path}/$name');

    try {
  final bytes = await doc.save();
  await file.writeAsBytes(bytes);
  return PdfResult(file.path, fontFound);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains("Widget won't fit into the page")) {
        // Fallback: rebuild document by splitting long paragraphs into smaller chunks
        final doc2 = pw.Document();
        doc2.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData(defaultTextStyle: base),
          header: (ctx) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(title, style: pw.TextStyle(font: mainFont, fontSize: 9, color: PdfColors.grey600)),
          ),
          footer: (ctx) => pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 8),
            child: pw.Text('Страница ${ctx.pageNumber} / ${ctx.pagesCount}', style: pw.TextStyle(font: mainFont, fontSize: 9, color: PdfColors.grey600)),
          ),
          build: (ctx) {
            final widgets = <pw.Widget>[];
            // crude split: break content into chunks of ~1000 chars
            final chunks = <String>[];
            var accum = StringBuffer();
            for (var part in content.replaceAll('\r\n', '\n').split('\n')) {
              if (accum.length + part.length > 1000) {
                chunks.add(accum.toString());
                accum = StringBuffer();
              }
              accum.writeln(part);
            }
            if (accum.isNotEmpty) chunks.add(accum.toString());

            for (var c in chunks) {
              widgets.add(pw.Paragraph(text: c, style: base));
              widgets.add(pw.SizedBox(height: 6));
            }
            return widgets;
          },
        ));
  final bytes2 = await doc2.save();
  await file.writeAsBytes(bytes2);
  return PdfResult(file.path, fontFound);
      }
      rethrow;
    }
  }
}

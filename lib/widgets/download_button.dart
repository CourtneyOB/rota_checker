import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:rota_checker/widgets/results_row.dart';
import 'package:rota_checker/constants.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'dart:typed_data';

class DownloadButton extends StatelessWidget {
  final List<ResultsRow> contents;

  List<pw.Widget> mapContents() {
    return contents
        .map((item) => pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 8.0),
            child: pw.Column(children: [
              pw.Padding(
                padding: pw.EdgeInsets.only(bottom: 8.0),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Padding(
                          padding: pw.EdgeInsets.only(right: 20.0),
                          child: pw.Text(
                            item.title,
                            style: pw.TextStyle(fontSize: 12.0),
                          )),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.only(left: 10.0, right: 20.0),
                      child: pw.Text(
                        item.result ? 'PASS' : 'FAIL',
                        style: pw.TextStyle(
                            fontSize: 12.0,
                            color: item.result
                                ? PdfColor.fromHex('4CAF50')
                                : PdfColor.fromHex('F44336')),
                      ),
                    ),
                    pw.Expanded(
                      flex: 6,
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 10.0, right: 20.0),
                        child: pw.Text(
                          item.explanation,
                          style: pw.TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('E6EBE9'))),
              ),
            ])))
        .toList();
  }

  DownloadButton({required this.contents});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            final pdf = pw.Document();
            pdf.addPage(pw.MultiPage(
              footer: (context) {
                return pw.Footer(
                    title: pw.Text(
                        'Page ${context.pageNumber.toString()} of ${context.pagesCount}'));
              },
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) => [
                pw.Row(children: [
                  pw.Text('Your Rota Compliance',
                      style: pw.TextStyle(
                          fontSize: 18.0, color: PdfColor.fromHex('007787'))),
                ]),
                pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 8.0),
                  child: pw.Row(children: [
                    pw.Text('Date entered: ${DateTime.now()}',
                        style: pw.TextStyle(color: PdfColor.fromHex('757575')))
                  ]),
                ),
                pw.Wrap(children: mapContents()),
              ],
            ));

            //Create PDF in Bytes
            Uint8List pdfInBytes = await pdf.save();

            //Create blob and link from bytes
            final blob = html.Blob([pdfInBytes], 'application/pdf');
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor =
                html.document.createElement('a') as html.AnchorElement
                  ..href = url
                  ..style.display = 'none'
                  ..download = 'example.pdf';
            html.document.body!.children.add(anchor);

            anchor.click();
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(5.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  color: kContrast),
              height: 24.0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Icon(
                          Icons.file_download,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, top: 2.0),
                        child: Text(
                          'Export',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

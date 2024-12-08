import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({Key? key}) : super(key: key);

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  File? _generatedPdf;

  Future<void> generatePdf(List<File> files) async {
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No files selected!')),
      );
      return;
    }

    final pdf = pw.Document();

    for (var file in files) {
      if (file.path.endsWith('.jpg') || file.path.endsWith('.png')) {
        final image = pw.MemoryImage(file.readAsBytesSync());
        pdf.addPage(pw.Page(build: (context) => pw.Image(image)));
      } else if (file.path.endsWith('.txt')) {
        final text = file.readAsStringSync();
        pdf.addPage(pw.Page(build: (context) => pw.Text(text)));
      }
    }

    final outputDir = await getApplicationDocumentsDirectory();
    final outputFile = File('${outputDir.path}/converted_file.pdf');
    await outputFile.writeAsBytes(await pdf.save());

    setState(() {
      _generatedPdf = outputFile;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF generated successfully!')),
    );
  }

  Future<void> sharePdf() async {
    if (_generatedPdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No PDF generated!')),
      );
      return;
    }

    final xFile = XFile(_generatedPdf!.path); // Create an XFile object
    await Share.shareXFiles([xFile], text: 'Here is your PDF file.');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Pass the files from the FilePickerScreen to this function
              generatePdf([]);
            },
            child: const Text('Generate PDF'),
          ),
          ElevatedButton(
            onPressed: sharePdf,
            child: const Text('Share PDF'),
          ),
        ],
      ),
    );
  }
}

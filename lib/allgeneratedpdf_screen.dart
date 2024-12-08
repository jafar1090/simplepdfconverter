import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneratedPdfScreen extends StatefulWidget {
  const GeneratedPdfScreen({Key? key}) : super(key: key);

  @override
  _GeneratedPdfScreenState createState() => _GeneratedPdfScreenState();
}
class _GeneratedPdfScreenState extends State<GeneratedPdfScreen> {
  // Initialize _pdfFiles with a Future that resolves to an empty list
  Future<List<File>> _pdfFiles = Future.value([]);

  String? _customSavePath;

  @override
  void initState() {
    super.initState();
    _loadSaveLocation();
    _loadPdfFiles();
  }

  Future<void> _loadSaveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customSavePath = prefs.getString('saveLocation');
    });
  }

  Future<void> _loadPdfFiles() async {
    final directoryPath = _customSavePath ??
        (await getApplicationDocumentsDirectory()).path;
    final pdfDir = Directory(directoryPath);
    final pdfFiles = pdfDir.listSync().where((item) {
      return item is File && item.path.endsWith('.pdf');
    }).map((item) => item as File).toList();

    setState(() {
      // Update the _pdfFiles variable with the loaded list of PDF files
      _pdfFiles = Future.value(pdfFiles);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated PDFs'),
      ),
      body: FutureBuilder<List<File>>(
        future: _pdfFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No PDFs found.'));
          }

          final pdfFiles = snapshot.data!;
          return ListView.builder(
            itemCount: pdfFiles.length,
            itemBuilder: (context, index) {
              final file = pdfFiles[index];
              return ListTile(
                title: Text(file.path.split('/').last),
                subtitle: Text(file.path),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () {
                    OpenFile.open(file.path); // Open the selected PDF
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

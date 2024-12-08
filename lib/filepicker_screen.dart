import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({Key? key}) : super(key: key);

  @override
  State<FilePickerScreen> createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  final List<File> _selectedFiles = [];

  Future<void> pickImages() async {
    final List<XFile>? images = await ImagePicker().pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedFiles.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.paths.map((path) => File(path!)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Files'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: pickImages,
            child: const Text('Pick Images'),
          ),
          ElevatedButton(
            onPressed: pickDocuments,
            child: const Text('Pick Documents'),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_selectedFiles[index].path.split('/').last),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

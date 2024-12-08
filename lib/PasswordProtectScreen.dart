import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';

class PasswordProtectScreen extends StatefulWidget {
  const PasswordProtectScreen({Key? key}) : super(key: key);

  @override
  State<PasswordProtectScreen> createState() => _PasswordProtectScreenState();
}

class _PasswordProtectScreenState extends State<PasswordProtectScreen> {
  File? _selectedFile;
  String? _password;

  Future<void> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF file selected: ${_selectedFile!.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> applyPasswordProtection() async {
    if (_selectedFile == null || _password == null || _password!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file and enter a password')),
      );
      return;
    }

    try {
      final inputFile = _selectedFile!;
      final encryptedData = _encryptFile(inputFile.readAsBytesSync(), _password!);

      final outputPath = '${(await getApplicationDocumentsDirectory()).path}/protected_${inputFile.uri.pathSegments.last}';
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(encryptedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved at $outputPath')),
      );

      setState(() {
        _selectedFile = null; // Reset the selected file
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error applying protection: $e')),
      );
    }
  }

  List<int> _encryptFile(List<int> fileBytes, String password) {
    final key = encrypt.Key.fromUtf8(password.padRight(32, '*').substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
    return encrypted.bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Protect PDF'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: pickPdfFile,
              icon: const Icon(Icons.file_open),
              label: const Text('Pick PDF File'),
            ),
            const SizedBox(height: 20),
            if (_selectedFile != null)
              Text('Selected file: ${_selectedFile!.path}'),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter Password',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: applyPasswordProtection,
              icon: const Icon(Icons.lock),
              label: const Text('Apply Password Protection'),
            ),
          ],
        ),
      ),
    );
  }
}

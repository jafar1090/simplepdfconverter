import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdfconverter_app/allgeneratedpdf_screen.dart';

import 'PasswordProtectScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _customSavePath;

  @override
  void initState() {
    super.initState();
    _loadSaveLocation();
  }


  // Method to load the save location from SharedPreferences
  Future<void> _loadSaveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customSavePath = prefs.getString('saveLocation') ?? 'No location set';
    });
  }

  // Method to change the save location and persist it
  Future<void> changeSaveLocation() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _customSavePath = '$result/converted_images.pdf';
      });

      // Save the new location in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saveLocation', _customSavePath!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save location set to: $result')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Save Location:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 10),
              Text(
                _customSavePath ?? 'No location set',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: changeSaveLocation,
                icon: const Icon(Icons.folder),
                label: const Text('Change Save Location'),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GeneratedPdfScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.folder),
                tooltip: 'View Generated PDFs',
              ),  ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PasswordProtectScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.folder),
                label: const Text('encrypt pdf'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

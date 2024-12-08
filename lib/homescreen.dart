import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfconverter_app/button.dart';
import 'package:pdfconverter_app/settings_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart'; // For PdfPageFormat

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<File> _selectedImages = [];
  File? _generatedPdf;
  String? _customSavePath;
  bool _isLoading = false;
  String? _generatedPdfPath; // Variable to store the generated PDF path.

  // PDF Settings
  String _pageOrientation = 'Portrait';
  String _pageSize = 'A4';
  double _margin = 20.0;

  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSaveLocation();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customSavePath = prefs.getString('saveLocation');
      _pageOrientation = prefs.getString('pageOrientation') ?? 'Portrait';
      _pageSize = prefs.getString('pageSize') ?? 'A4';
      _margin = prefs.getDouble('margin') ?? 20.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pageOrientation', _pageOrientation);
    await prefs.setString('pageSize', _pageSize);
    await prefs.setDouble('margin', _margin);
  }

  Future<void> _loadSaveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customSavePath = prefs.getString('saveLocation') ?? 'No location set';
      print('Loaded save location: $_customSavePath');
    });
  }

  void _initializeNotifications() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);
    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          OpenFile.open(response.payload);
        }
      },
    );
  }

  Future<void> _showNotification(String pdfPath) async {
    const androidDetails = AndroidNotificationDetails(
      'pdf_channel',
      'PDF Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      'PDF Generated',
      'Tap to open the PDF',
      notificationDetails,
      payload: pdfPath,
    );
  }

  Future<void> _savePdfPath(String pdfPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastGeneratedPdf', pdfPath);
  }

  Future<void> pickImages() async {
    try {
      final List<XFile>? images = await ImagePicker().pickMultiImage();
      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${images.length} images selected')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No images selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _pageOrientation,
              items: ['Portrait', 'Landscape']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _pageOrientation = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Orientation'),
            ),
            DropdownButtonFormField<String>(
              value: _pageSize,
              items: ['A4', 'Letter']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _pageSize = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Page Size'),
            ),
            TextFormField(
              initialValue: _margin.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Margin (px)'),
              onChanged: (value) {
                setState(() {
                  _margin = double.tryParse(value) ?? 20.0;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _saveSettings();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> generatePdf() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images selected!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Define custom page format and orientation
    final pageFormat = PdfPageFormat.a4; // For A4 size
    final pdf = pw.Document();

    for (var i = 0; i < _selectedImages.length; i++) {
      final imageMemory = pw.MemoryImage(_selectedImages[i].readAsBytesSync());
      pdf.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            pageFormat: pageFormat,
            orientation:
                pw.PageOrientation.portrait, // Change to landscape if needed
          ),
          build: (context) => pw.Center(child: pw.Image(imageMemory)),
        ),
      );
    }

    final savePath = _customSavePath ??
        '${(await getApplicationDocumentsDirectory()).path}/converted_images.pdf';
    final outputFile = File(savePath);
    await outputFile.writeAsBytes(await pdf.save());

    setState(() {
      _generatedPdf = outputFile;
      _isLoading = false;
    });

    _savePdfPath(outputFile.path);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF generated successfully!')),
    );

    _showNotification(outputFile.path);
  }

  Future<void> sharePdf() async {
    if (_generatedPdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No PDF generated!')),
      );
      return;
    }
    final xFile = XFile(_generatedPdf!.path);
    await Share.shareXFiles([xFile], text: 'Here is your PDF file.');
  }

  Future<void> uploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'csv'
      ],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      setState(() {
        _generatedPdf = file;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document uploaded: ${file.path}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document selected')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _previewImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            itemCount: _selectedImages.length,
            builder: (context, galleryIndex) {
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(_selectedImages[galleryIndex]),
              );
            },
            pageController: PageController(initialPage: index),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(),
                    ));
              },
              icon: Icon(Icons.settings)),
          IconButton(
              onPressed: () {
                _showSettingsDialog();
              },
              icon: Icon(Icons.edit))
        ],
        title: const Text('Image to PDF Converter'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: pickImages,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Pick Images'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: uploadDocument,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Document'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // PDF saved path display
                  if (_generatedPdf != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'PDF saved at: ${_generatedPdf!.path}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ),

                  // Image Grid display
                  if (_selectedImages.isEmpty)
                    const Center(
                      child: Text('No images selected!',
                          style: TextStyle(fontSize: 18)),
                    )
                  else
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _previewImage(index),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImages[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Generate PDF button
                  if (_selectedImages.isNotEmpty || _generatedPdf != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 90),
                      child: NeonButton  (
                        onPressed: generatePdf, label: 'generate pdf',
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}


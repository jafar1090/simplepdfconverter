// import 'package:flutter/material.dart';
// import 'package:pdfconverter_app/filepicker_screen.dart';
// import 'package:pdfconverter_app/pdfpriview_screen.dart';
//
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const FilePickerScreen()),
//                 );
//               },
//               child: const Text('Pick Files'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const PdfPreviewScreen()),
//                 );
//               },
//               child: const Text('View PDF'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

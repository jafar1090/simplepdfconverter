import 'package:flutter/material.dart';

import 'calc.dart';
import 'homescreen.dart';
import 'newcalc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {



  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image & Document to PDF',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:  newcc(),
    );
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:match_test/pdf_home.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    initializePdfDirectory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PdfHome(),
    );
  }

  Future<void> initializePdfDirectory() async {
    try {
      // Get the application documents directory (or external storage directory on Android)
      final appDir = await getApplicationDocumentsDirectory();

      // Create a new directory within the app documents directory
      final newFolderPath = '${appDir.path}/pdf';
      final newDir = Directory(newFolderPath);

      // Check if the directory already exists
      if (!newDir.existsSync()) {
        // Create the directory
        newDir.createSync(recursive: true);
        log('App directory initialized. Created folder: $newFolderPath');
      } else {
        log('App directory already initialized. Folder exists: $newFolderPath');
      }
    } catch (e) {
      log(e.toString());
    }
  }
}

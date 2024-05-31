import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx_plugin/pdfx_plugin.dart';
// import 'package:pdf_render_scroll/pdf_render.dart';
// import 'package:pdf_render/pdf_render_widgets.dart';
// import 'package:pdfrx/pdfrx.dart';
import 'pdf_renderer.dart';

class PdfHome extends StatefulWidget {
  const PdfHome({super.key});

  @override
  State<PdfHome> createState() => _PdfHomeState();
}

class _PdfHomeState extends State<PdfHome> {
  // PdfViewerController? pdfController;
  String? filePath;

  final pdfPinchController = PdfControllerPinch(
    document: PdfDocument.openAsset('assets/random.pdf'),
  );
  final pdfController = PdfController(
    document: PdfDocument.openAsset('assets/random.pdf'),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const PdfViewPage(),
      // body: PdfViewer.asset(
      //   'assets/random.pdf',
      //   params: PdfViewerParams(),
      // ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.first_page),
        onPressed: () async {
          await _pickFile();
        },
      ),
    );
  }

  Future<String> _pickFile() async {
    final file = await FilePicker.platform.pickFiles(
      compressionQuality: 10,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (file != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final dirPath = '${appDir.path}/pdf';
      final fileName = basename(file.paths[0] ?? '');
      final selectedFile = File(file.paths[0] ?? '');
      final destinationFilePath = '$dirPath/$fileName';
      final newPath = await selectedFile.copy(destinationFilePath);
      return newPath.path;
    } else {
      return '';
    }
  }
}

class PdfViewPage extends StatefulWidget {
  const PdfViewPage({super.key});

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  int _pageCount = 0;
  String pdfPath =
      '/data/user/0/com.example.match_test/app_flutter/pdf/random.pdf';

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    _pageCount = await PdfRenderer.getPageCount(pdfPath);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('PDF Viewer'),
        ),
        body: _pageCount == null
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder(
                future: PdfRenderer.renderPage(
                  pdfPath,
                  0,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasError) {
                      return const Text(
                        'File not found. Please upload by clicking floating button and upload rando.pdf. The restart app',
                      );
                    }
                    if (snapshot.hasData) {
                      // return ListView.builder(
                      //   scrollDirection: Axis.vertical,
                      //   itemCount: snapshot.data!.length,
                      //   itemBuilder: (context, index) {
                      //     return  Container(
                      //       height: 500,
                      //       child: PhotoView(
                      //         imageProvider: MemoryImage(
                      //             snapshot.data![index] as Uint8List),
                      //         minScale: PhotoViewComputedScale.contained * 0.8,
                      //         maxScale: PhotoViewComputedScale.covered * 2.5,
                      //         backgroundDecoration:
                      //             BoxDecoration(color: Colors.white),
                      //       ),
                      //     );
                      //   },
                      // );
                      return PhotoView.customChild(
                        minScale: PhotoViewComputedScale.contained * 1,
                        maxScale: PhotoViewComputedScale.contained * 5,
                        child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) => Image.memory(
                                color: Colors.white,
                                snapshot.data![index] as Uint8List)),
                      );
                      return PhotoViewGallery.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data!.length,
                        builder: (context, index) {
                          return PhotoViewGalleryPageOptions(
                              imageProvider: MemoryImage(
                                  snapshot.data![index] as Uint8List),
                              minScale: PhotoViewComputedScale.contained * 1,
                              maxScale: PhotoViewComputedScale.covered * 2.5,
                              tightMode: true);
                        },
                        scrollPhysics: const BouncingScrollPhysics(),
                        backgroundDecoration:
                            const BoxDecoration(color: Colors.white),
                      );
                      // return Column(
                      //   children: [
                      //     Expanded(
                      //       child: ListView.builder(
                      //         itemCount: snapshot.data!.length,
                      //         itemBuilder: (context, index) => Container(
                      //           height: 500,
                      //           child: PhotoView(
                      //             backgroundDecoration:
                      //                 BoxDecoration(color: Colors.white),
                      //             imageProvider: MemoryImage(
                      //               snapshot.data![index] as Uint8List,
                      //             ),
                      //             minScale:
                      //                 PhotoViewComputedScale.contained * 1,
                      //             maxScale:
                      //                 PhotoViewComputedScale.covered * 2.5,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // );
                      // return Text('Pdf Loaded');
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }
                },
              )
        // : ListView.builder(
        //     itemCount: _pageCount,
        //     itemBuilder: (context, index) {
        //       return FutureBuilder(
        //         future: PdfRenderer.renderPage(pdfPath, index + 1),
        //         builder: (context, snapshot) {
        //           if (snapshot.connectionState == ConnectionState.waiting) {
        //             return Center(child: CircularProgressIndicator());
        //           } else {
        //             return Image.memory(snapshot.data as Uint8List);
        //           }
        //         },
        //       );
        //     },
        //   ),
        );
  }
}

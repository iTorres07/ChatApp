import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatelessWidget {
  final String pdfUrl; // Agrega la variable pdfUrl al constructor

  const PdfViewer(this.pdfUrl, {Key? key})
      : super(key: key); // Actualiza el constructor

  @override
  Widget build(BuildContext context) {
    final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context); // Regresar a la vista anterior al presionar el botón
          },
        ),
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        key: pdfViewerKey,
      ),
    );
  }
}

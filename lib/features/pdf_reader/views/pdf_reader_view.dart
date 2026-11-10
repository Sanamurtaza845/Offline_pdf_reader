import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'dart:io';

class PdfReaderView extends StatefulWidget {
  final String filePath;

  const PdfReaderView({
    super.key,
    required this.filePath,
  });

  @override
  State<PdfReaderView> createState() => _PdfReaderViewState();
}

class _PdfReaderViewState extends State<PdfReaderView> {
  late final PdfViewerController pdfController;
  final TextEditingController pageNumberController =
    TextEditingController();

  int currentPage = 1;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();

    pdfController = PdfViewerController();
  }

 @override
void dispose() {
  pageNumberController.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    final fileName = widget.filePath.split('/').last;

    return Scaffold(
     appBar: AppBar(
  title: Text(
    fileName,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
  ),
  actions: [
    IconButton(
      onPressed: _showPdfInfo,
      icon: const Icon(Icons.info_outline),
      tooltip: 'PDF Information',
    ),
  ],
),

      body: Stack(
        children: [

          PdfViewer.file(
            widget.filePath,
            controller: pdfController,
            params: PdfViewerParams(
              onDocumentChanged: (document) {
                if (document != null && mounted) {
                  setState(() {
                    totalPages = document.pages.length;
                  });
                }
              },

              onPageChanged: (pageNumber) {
                if (mounted && pageNumber != null) {
                  setState(() {
                    currentPage = pageNumber;
                  });
                }
              },
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,

           child: Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 6,
  ),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(20),
        blurRadius: 10,
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: currentPage > 1 && pdfController.isReady
            ? () => pdfController.goToPage(
                  pageNumber: currentPage - 1,
                )
            : null,
        icon: const Icon(Icons.chevron_left),
      ),

      Flexible(
        child: InkWell(
          onTap: pdfController.isReady && totalPages > 0
              ? _showPageJumpDialog
              : null,
          child: Text(
            '$currentPage / $totalPages',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: currentPage < totalPages && pdfController.isReady
            ? () => pdfController.goToPage(
                  pageNumber: currentPage + 1,
                )
            : null,
        icon: const Icon(Icons.chevron_right),
      ),

      IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: pdfController.isReady
            ? () => pdfController.zoomDown()
            : null,
        icon: const Icon(Icons.zoom_out),
      ),

      IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: pdfController.isReady
            ? () => pdfController.zoomUp()
            : null,
        icon: const Icon(Icons.zoom_in),
      ),
    ],
  ),
),
          )
        ]),
    );
  }
  Future<void> _showPageJumpDialog() async {
  pageNumberController.text = currentPage.toString();

  final page = await showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: pageNumberController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter page number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final number = int.tryParse(
                pageNumberController.text.trim(),
              );

              if (number == null ||
                  number < 1 ||
                  number > totalPages) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Enter a page between 1 and $totalPages',
                    ),
                  ),
                );
                return;
              }

              Navigator.pop(context, number);
            },
            child: const Text('Go'),
          ),
        ],
      );
    },
  );

  if (page != null && pdfController.isReady) {
    pdfController.goToPage(pageNumber: page);
  }
}
void _showPdfInfo() async {
  final file = File(widget.filePath);

  if (!await file.exists()) return;

  final size = await file.length();
  final modified = await file.lastModified();

  String fileSize;

  if (size < 1024 * 1024) {
    fileSize = '${(size / 1024).toStringAsFixed(2)} KB';
  } else {
    fileSize = '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  if (!mounted) return;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('PDF Information'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('File Name', file.uri.pathSegments.last),
          _infoRow('Total Pages', '$totalPages'),
          _infoRow('File Size', fileSize),
          _infoRow('Location', file.path),
          _infoRow('Modified', modified.toString().split('.')[0]),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Widget _infoRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 3),
        SelectableText(
          value,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}
}
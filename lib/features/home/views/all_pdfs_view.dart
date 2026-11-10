import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/home_controller.dart';
import '../../pdf_reader/views/pdf_reader_view.dart';
import 'package:share_plus/share_plus.dart';

class AllPdfsView extends StatelessWidget {
  const AllPdfsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All PDFs',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
  Obx(
    () => IconButton(
      onPressed: controller.toggleView,
      icon: Icon(
        controller.isGridView.value
            ? Icons.view_list
            : Icons.grid_view,
      ),
      tooltip: controller.isGridView.value
          ? 'List View'
          : 'Grid View',
    ),
  ),
],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // Search Bar
            TextField(
              onChanged: (value) {
                controller.searchQuery.value = value;
              },
              decoration: InputDecoration(
                hintText: 'Search PDF documents...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
            ),

const SizedBox(height: 15),

// Sorting Options
Obx(
  () => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        'All Documents',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.dark,
        ),
      ),

      DropdownButton<String>(
        value: controller.sortBy.value,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(
            value: 'Newest',
            child: Text('Newest'),
          ),
          DropdownMenuItem(
            value: 'Oldest',
            child: Text('Oldest'),
          ),
          DropdownMenuItem(
            value: 'Name',
            child: Text('Name'),
          ),
          DropdownMenuItem(
            value: 'Size',
            child: Text('Size'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.sortBy.value = value;
          }
        },
      ),
    ],
  ),
),

            const SizedBox(height: 20),

            // PDF List
            Expanded(
              child: Obx(() {

                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final files = controller.allPdfFiles;

                if (files.isEmpty) {
                  return const Center(
                    child: Text(
                      'No PDFs Found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey,
                      ),
                    ),
                  );
                }

                return controller.isGridView.value
    ? GridView.builder(
        itemCount: files.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final file = files[index];

          return _buildPdfCard(context, file, controller);
        },
      )
    : ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];

          return _buildPdfCard(context, file, controller);
        },
      );
              }),
            ),
          ],
        ),
      ),
      
    );
  }
Widget _buildPdfCard(
  BuildContext context,
  File file,
  HomeController controller,
) {
  final fileName =
      file.path.split(Platform.pathSeparator).last;

  return Card(
    color: Colors.white,
    elevation: 0,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.border),
    ),
    child: controller.isGridView.value
        ? Stack(
            children: [
              InkWell(
                onTap: () {
                  Get.to(
                    () => PdfReaderView(filePath: file.path),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 35, 10, 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        controller.getFileSize(file),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 0,
                right: 0,
                child: _pdfMenu(file, controller),
              ),
            ],
          )
        : ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: const Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 35,
            ),
            title: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'PDF Document • ${controller.getFileSize(file)}',
            ),
            trailing: _pdfMenu(file, controller),
            onTap: () {
              Get.to(
                () => PdfReaderView(filePath: file.path),
              );
            },
          ),
  );
}
  
  Widget _pdfMenu(File file, HomeController controller) {
  return PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert),
    onSelected: (value) async {
      if (value == 'rename') {
        final newName = await Get.dialog<String>(
          RenamePdfDialog(
            initialName: file.path
                .split(Platform.pathSeparator)
                .last
                .replaceAll(
                  RegExp(r'\.pdf$', caseSensitive: false),
                  '',
                ),
          ),
        );

        if (newName != null && newName.isNotEmpty) {
          await controller.renamePdf(file, newName);
        }
      }

      if (value == 'delete') {
        Get.dialog(
          AlertDialog(
            title: const Text('Delete PDF?'),
            content: const Text(
              'Are you sure you want to delete this document?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  controller.deletePdf(file);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      }

      if (value == 'share') {
        try {
          if (!await file.exists()) {
            Get.snackbar('Error', 'PDF file not found.');
            return;
          }

          final result = await SharePlus.instance.share(
            ShareParams(
              files: [
                XFile(file.path, mimeType: 'application/pdf'),
              ],
              title: 'Share PDF',
              subject: 'PDF Document',
            ),
          );

          debugPrint('Share result: ${result.status}');
        } catch (e) {
          debugPrint('SHARE ERROR: $e');

          Get.snackbar(
            'Share Error',
            e.toString(),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    },
    itemBuilder: (context) => const [
      PopupMenuItem(
        value: 'rename',
        child: Row(
          children: [
            Icon(Icons.edit_outlined),
            SizedBox(width: 10),
            Text('Rename'),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('Delete'),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'share',
        child: Row(
          children: [
            Icon(Icons.share_outlined),
            SizedBox(width: 10),
            Text('Share'),
          ],
        ),
      ),
    ],
  );
}
}
class RenamePdfDialog extends StatefulWidget {
  final String initialName;

  const RenamePdfDialog({
    super.key,
    required this.initialName,
  });

  @override
  State<RenamePdfDialog> createState() =>
      _RenamePdfDialogState();
}

class _RenamePdfDialogState extends State<RenamePdfDialog> {
  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.initialName,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename PDF'),
      content: TextField(
        controller: nameController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Enter new PDF name',
          suffixText: '.pdf',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text.trim();

            if (name.isEmpty) {
              Get.snackbar(
                'Invalid Name',
                'Please enter a PDF name.',
              );
              return;
            }

            Get.back(result: name);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
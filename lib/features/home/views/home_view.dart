import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/home_controller.dart';
import '../../pdf_reader/views/pdf_reader_view.dart';
import 'all_pdfs_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PDF Reader',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
     
       actions: [
  IconButton(
    onPressed: () {
      Get.to(() => const AllPdfsView());
    },
    icon: const Icon(Icons.search),
    tooltip: 'Search PDFs',
  ),
],
    
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Your Documents',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Read your PDFs anytime, anywhere.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // Import PDF Button

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: controller.importPdf,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Import PDF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),



            const SizedBox(height: 30),

            const Text(
              'Recently Added',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
  child: Obx(() {
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final recentFiles = controller.recentPdfFiles;

    if (recentFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 75,
              color: AppColors.grey.withAlpha(120),
            ),
            const SizedBox(height: 15),
            const Text(
              'No Recent PDFs',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PDFs imported in the last 24 hours will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: recentFiles.length,
      itemBuilder: (context, index) {
        final file = recentFiles[index];

        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(
              color: AppColors.border,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
                size: 28,
              ),
            ),
            title: Text(
              file.path.split(Platform.pathSeparator).last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
          subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'PDF Document • ${controller.getFileSize(file)}',
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.grey,
      ),
    ),
    const SizedBox(height: 4),
    Text(
      controller.getImportDate(file),
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.grey,
      ),
    ),
  ],
),
            trailing: IconButton(
              onPressed: () {
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
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
            onTap: () {
              Get.to(
                () => PdfReaderView(filePath: file.path),
              );
            },
          ),
        );
      },
    );
  }),
),
          ],
        ),
      ),
    );
  }
}
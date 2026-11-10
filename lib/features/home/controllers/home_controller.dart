import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class HomeController extends GetxController {
  final RxList<File> pdfFiles = <File>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'Newest'.obs;
  final RxBool isGridView = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPdfFiles();
  }
  void toggleView() {
  isGridView.value = !isGridView.value;
}

// All PDFs sorted by newest first
List<File> get allPdfFiles {
  final files = pdfFiles.toList();

  switch (sortBy.value) {
    case 'Oldest':
      files.sort(
        (a, b) => a.lastModifiedSync().compareTo(
          b.lastModifiedSync(),
        ),
      );
      break;

    case 'Name':
      files.sort(
        (a, b) => a.path
            .split(Platform.pathSeparator)
            .last
            .toLowerCase()
            .compareTo(
              b.path
                  .split(Platform.pathSeparator)
                  .last
                  .toLowerCase(),
            ),
      );
      break;

    case 'Size':
      files.sort(
        (a, b) => b.lengthSync().compareTo(a.lengthSync()),
      );
      break;

    default:
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(
          a.lastModifiedSync(),
        ),
      );
  }

  if (searchQuery.value.isEmpty) {
    return files;
  }

  return files.where((file) {
    final name = file.path.split(Platform.pathSeparator).last;

    return name.toLowerCase().contains(
      searchQuery.value.toLowerCase(),
    );
  }).toList();
}
// Only 3 PDFs imported within the last 24 hours
List<File> get recentPdfFiles {
  final yesterday = DateTime.now().subtract(
    const Duration(hours: 24),
  );

  final recentFiles = pdfFiles.where((file) {
    return file.lastModifiedSync().isAfter(yesterday);
  }).toList();

  recentFiles.sort(
    (a, b) => b.lastModifiedSync().compareTo(
      a.lastModifiedSync(),
    ),
  );

  return recentFiles.take(5).toList();
}
  // Load PDFs from local app storage
  Future<void> loadPdfFiles() async {
    try {
      isLoading.value = true;

      final directory =
          await getApplicationDocumentsDirectory();

      final files = directory
          .listSync()
          .where(
            (file) =>
                file.path.toLowerCase().endsWith('.pdf'),
          )
          .map((file) => File(file.path))
          .toList();

      pdfFiles.assignAll(files);

      debugPrint('Total PDFs found: ${pdfFiles.length}');
    } catch (e) {
      debugPrint('Loading PDFs error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Import PDF
  Future<void> importPdf() async {
    try {
      final pickedFile = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (pickedFile == null) return;

      isLoading.value = true;

     final bytes = await pickedFile.readAsBytes();

final directory = await getApplicationDocumentsDirectory();

// Check whether this PDF already exists.
final existingFiles = directory
    .listSync()
    .where(
      (file) => file.path.toLowerCase().endsWith('.pdf'),
    );

for (final existingFile in existingFiles) {
  final existing = File(existingFile.path);

  if (await existing.length() == bytes.length) {
    final existingBytes = await existing.readAsBytes();

    if (existingBytes.length == bytes.length &&
        List<int>.generate(
          bytes.length,
          (index) => bytes[index] ^ existingBytes[index],
        ).every((value) => value == 0)) {
      isLoading.value = false;

      Get.snackbar(
        'Already Exists',
        'This PDF has already been imported.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }
  }
}

      String fileName = pickedFile.name;

      String destinationPath =
          '${directory.path}/$fileName';

      if (await File(destinationPath).exists()) {
        final name = fileName.replaceAll(
          RegExp(r'\.pdf$', caseSensitive: false),
          '',
        );

        fileName =
            '${name}_${DateTime.now().millisecondsSinceEpoch}.pdf';

        destinationPath =
            '${directory.path}/$fileName';
      }

      final savedFile = File(destinationPath);

      await savedFile.writeAsBytes(bytes, flush: true);

      await loadPdfFiles();

      Get.snackbar(
        'Success',
        'PDF imported successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('PDF import error: $e');

      Get.snackbar(
        'Error',
        'Unable to import PDF.',
        snackPosition: SnackPosition.BOTTOM,
      );

      isLoading.value = false;
    }
  }
  Future<void> deletePdf(File file) async {
  try {
    if (await file.exists()) {
      await file.delete();
    }

    pdfFiles.removeWhere(
      (pdf) => pdf.path == file.path,
    );

    Get.snackbar(
      'Deleted',
      'PDF deleted successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    debugPrint('Delete PDF error: $e');

    Get.snackbar(
      'Error',
      'Unable to delete PDF.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
// Get PDF file size
String getFileSize(File file) {
  final bytes = file.lengthSync();

  if (bytes < 1024) {
    return '$bytes B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  } else {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
String getImportDate(File file) {
  final date = file.lastModifiedSync();
  final now = DateTime.now();

  final difference = now.difference(date);

  String formatTime() {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  if (difference.inDays == 0 && date.day == now.day) {
    return 'Today, ${formatTime()}';
  }

  if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day - 1) {
    return 'Yesterday, ${formatTime()}';
  }

  return '${date.day}/${date.month}/${date.year}, ${formatTime()}';
}
// Rename PDF
Future<void> renamePdf(File file, String newName) async {
  try {
    newName = newName.trim();

    if (newName.isEmpty) return;

    // Remove .pdf if user already entered it.
    newName = newName.replaceAll(
      RegExp(r'\.pdf$', caseSensitive: false),
      '',
    );

    final directory = file.parent;
    final newPath = '${directory.path}/$newName.pdf';

    if (file.path == newPath) return;

    if (await File(newPath).exists()) {
      Get.snackbar(
        'Already Exists',
        'A PDF with this name already exists.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final renamedFile = await file.rename(newPath);

    pdfFiles.removeWhere(
      (pdf) => pdf.path == file.path,
    );

    pdfFiles.add(renamedFile);

    Get.snackbar(
      'Success',
      'PDF renamed successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    debugPrint('Rename PDF error: $e');

    Get.snackbar(
      'Error',
      'Unable to rename PDF.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
}
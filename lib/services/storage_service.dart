import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class StorageService {
  Future<String> saveReceiptImage(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destinationPath = join(directory.path, fileName);
    
    final file = File(sourcePath);
    await file.copy(destinationPath);
    
    return destinationPath;
  }
}

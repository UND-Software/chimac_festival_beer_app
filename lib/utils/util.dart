
import 'dart:io';
import 'package:path_provider/path_provider.dart';


bool containsSubstring(String mainString, List<String> substrings) {
  for (String substring in substrings) {
    if (mainString.contains(substring)) {
      return true;
    }
  }
  return false;
}

class FileManager {
  final String fileName;

  FileManager(this.fileName);

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  Future<File> _getFile() async {
    final path = await _getFilePath();
    return File(path);
  }

  Future<void> writeToFile(String content) async {
    final file = await _getFile();
    await file.writeAsString(content, mode: FileMode.write);
  }

  Future<String> readFromFile() async {
    try {
      final file = await _getFile();
      String content = await file.readAsString();
      return content;
    } catch (e) {
      return 'Error reading file: $e';
    }
  }
}
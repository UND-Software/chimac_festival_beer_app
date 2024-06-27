
import 'dart:io';
import 'package:flutter/services.dart';
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
  String content = '';

  FileManager(this.fileName);

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  Future<String> readFile() async {
    String content;
    try {
      final file = await _getLocalFile();
      content = await file.readAsString();
      
    } catch (e) {
        content = '읽기 오류: $e';
    }
    return content;
  }

  Future<void> _writeToFile(String content) async {
    final file = await _getLocalFile();
    await file.writeAsString(content);
  }

  void modifyFile(String content) async {
    await _writeToFile(content);
  }
}
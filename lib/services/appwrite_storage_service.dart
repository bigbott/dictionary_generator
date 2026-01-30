import 'dart:io';
//import 'package:appwrite/appwrite.dart';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dictionary_generator/secret_constants.dart';

final class AppwriteStorageService {
  late final Client _client;
  late final Storage _storage;

  AppwriteStorageService._() {
    _client = Client()
      ..setEndpoint(SecretConstants.appwriteEndpoint)
      ..setProject(SecretConstants.appwriteProjectId);
    
    _storage = Storage(_client);
  }

  static final _instance = AppwriteStorageService._();
  factory AppwriteStorageService() => _instance;

  Future<String> upload(String pathToFile, {String? fileId}) async {
    try {
      final file = File(pathToFile);
      if (!await file.exists()) {
        throw Exception('File not found at path: $pathToFile');
      }

      final fileName = pathToFile.split(Platform.pathSeparator).last;
      final inputFile = InputFile.fromPath(path: pathToFile, filename: fileName);

      final result = await _storage.createFile(
        bucketId: SecretConstants.audioBucketId,
        fileId: fileName, //fileId ?? ID.unique(),
        file: inputFile,
      );

      return result.$id;
    } catch (e) {
      print(e);
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      await _storage.deleteFile(
        bucketId: SecretConstants.audioBucketId,
        fileId: fileId,
      );
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<String> getFileUrl(String fileId) async {
    try {
      final result = _storage.getFileView(
        bucketId: SecretConstants.audioBucketId,
        fileId: fileId,
      );
      return result.toString();
    } catch (e) {
      throw Exception('Failed to get file URL: $e');
    }
  }
}
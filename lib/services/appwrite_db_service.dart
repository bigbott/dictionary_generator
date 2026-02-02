import 'dart:io';
import 'package:dart_appwrite/dart_appwrite.dart';

//import 'package:appwrite/appwrite.dart';
import 'package:path/path.dart' as path;
import 'package:dictionary_generator/secret_constants.dart';
import 'package:dictionary_generator/models/appwrite/word.dart';
import 'package:dictionary_generator/models/dictionary/entry.dart';
import 'package:dictionary_generator/config.dart';

final class AppwriteDbService {
  late final Client _client;
  late final Databases _databases;

  AppwriteDbService._() {
    _client = Client()
      ..setEndpoint(SecretConstants.appwriteEndpoint)
      ..setKey(SecretConstants.appwriteApiKey)
      ..setProject(SecretConstants.appwriteProjectId);

    _databases = Databases(_client);
  }

  static final _instance = AppwriteDbService._();
  factory AppwriteDbService() => _instance;

  Future<Word> createWord(Word word) async {
    try {
      final document = await _databases.createDocument(
        databaseId: SecretConstants.dbId,
        collectionId: SecretConstants.wordsCollectionId,
        documentId: ID.unique(),
        data: {
          'word': word.word,
          'frequency': word.frequency,
          'json': word.json,
          'meanings': word.meanings,
          'forms': word.forms,
          'parts_of_speech': word.partsOfSpeech,
        },
      );

      var wordDb = Word.fromJson(document.data);

      return wordDb;
    } catch (e) {
      print('Error creating word document: $e');
      throw Exception('Failed to create word document: $e');
    }
  }

  Future<Word?> getWord(String documentId) async {
    try {
      final document = await _databases.getDocument(
        databaseId: SecretConstants.dbId,
        collectionId: SecretConstants.wordsCollectionId,
        documentId: documentId,
      );

      return Word.fromJson(document.data);
    } catch (e) {
      print('Error getting word document: $e');
      return null;
    }
  }

  Future<List<Word>> getWords({int? limit, int? offset}) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: SecretConstants.dbId,
        collectionId: SecretConstants.wordsCollectionId,
        queries: [
          if (limit != null) Query.limit(limit),
          if (offset != null) Query.offset(offset),
        ],
      );

      return response.documents.map((doc) => Word.fromJson(doc.data)).toList();
    } catch (e) {
      print('Error getting words: $e');
      return [];
    }
  }

  Future<Word> updateWord({required String documentId, Word? word}) async {
    try {
      final data = <String, dynamic>{};
      if (word != null) {
        data['word'] = word.word;
        data['frequency'] = word.frequency;
        data['json'] = word.json;
        data['meanings'] = word.meanings;
        data['forms'] = word.forms;
        data['parts_of_speech'] = word.partsOfSpeech;
      }

      final document = await _databases.updateDocument(
        databaseId: SecretConstants.dbId,
        collectionId: SecretConstants.wordsCollectionId,
        documentId: documentId,
        data: data,
      );

      return Word.fromJson(document.data);
    } catch (e) {
      print('Error updating word document: $e');
      throw Exception('Failed to update word document: $e');
    }
  }

  Future<void> deleteWord(String documentId) async {
    try {
      await _databases.deleteDocument(
        databaseId: SecretConstants.dbId,
        collectionId: SecretConstants.wordsCollectionId,
        documentId: documentId,
      );
    } catch (e) {
      print('Error deleting word document: $e');
      throw Exception('Failed to delete word document: $e');
    }
  }

  Future<void> fillDb() async {
    File progressFile = File(Config.dbProgress);
    List<String> progress = progressFile.readAsLinesSync();
    File failsFile = File(Config.dbFails);
    File difFile = File(Config.dbDif);
    List<String> dif = difFile.readAsLinesSync();
    try {
      final jsonDir = Directory(Config.jsonDir);

      if (!await jsonDir.exists()) {
        print('JSON directory does not exist: ${Config.jsonDir}');
        return;
      }

      final jsonFiles = jsonDir.listSync().where((file) {
        return file is File && file.path.endsWith('.txt');
      }).cast<File>();

      print('Found ${jsonFiles.length} JSON files to process');

      for (final jsonFile in jsonFiles) {
        Future.delayed(Duration(seconds: 1));
        try {
          final jsonContent = await jsonFile.readAsString();

          final entry = Entry.fromJson(jsonContent);
          if (!dif.contains(entry.word)){
            print(entry.word + ' is not in dif');
            continue;
          }
          if (progress.contains(entry.word)) {
            print(entry.word + ' is in progress');
            continue;
          }
          // Extract frequency from filename (pattern: word_frequency.json)
          final filename = path.basenameWithoutExtension(jsonFile.path);
          
          final frequency = _extractFrequencyFromFilename(filename);

          final entryWithFrequency = entry.copyWith(frequency: frequency);

          final word = Word.fromEntry(entryWithFrequency);
          print('${word.word} ${word.frequency}');

          // Upload to Appwrite
          try {
            await createWord(word);
            progressFile.writeAsStringSync('${entry.word}\n', mode: FileMode.append);
          } on Exception catch (e) {
            failsFile.writeAsStringSync('${entry.word} (${e.toString()})\n', mode: FileMode.append);
            rethrow;
          }

          print('Successfully uploaded word: ${word.word} (frequency: $frequency)');
        } catch (e) {
          print('Error processing file ${jsonFile.path}: $e');
          
          continue;
        }
      }

      print('Upload process completed');
    } catch (e) {
      print('Error in runUploads: $e');
      throw Exception('Failed to run uploads: $e');
    }
  }

  int _extractFrequencyFromFilename(String filename) {
    try {
      // Pattern: word_frequency (e.g., "hello_1234")
      final parts = filename.split('_');
      if (parts.length >= 2) {
        return int.tryParse(parts.last) ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error extracting frequency from filename: $filename, using 0');
      return 0;
    }
  }
}

  void printMissingFiles() {
    try {
      final progressFile = File(Config.progress);
      final dbProgressFile = File(Config.dbProgress);

      if (!progressFile.existsSync()) {
        print('Progress file does not exist: ${Config.progress}');
        return;
      }

      if (!dbProgressFile.existsSync()) {
        print('DB Progress file does not exist: ${Config.dbProgress}');
        return;
      }

      final progressWords = progressFile.readAsLinesSync().toSet();
      final dbProgressWords = dbProgressFile.readAsLinesSync().toSet();

      final missingInDb = progressWords.difference(dbProgressWords);

      if (missingInDb.isNotEmpty) {
        for (final word in missingInDb) {
          print(word);
        }
      }
    } catch (e) {
      print('Error comparing progress files: $e');
    }
  }


void diff() {
  printMissingFiles();
}

void main() {
  AppwriteDbService().fillDb();
  //diff();
}

import 'dart:io';
import 'package:isar/isar.dart';
import 'package:dictionary_generator/models/isar/word.dart';
import 'package:dictionary_generator/models/dictionary/entry.dart';
import 'package:dictionary_generator/config.dart';
import 'package:path/path.dart' as path;

final class IsarDbService {
  late final Isar _isar;
  bool _initialized = false;

  IsarDbService._();

  static final _instance = IsarDbService._();
  factory IsarDbService() => _instance;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final dir = Directory.current;
      final isarPath = path.join(dir.path, 'isar_db');
      
      _isar = await Isar.open(
        [WordSchema],
        directory: isarPath,
      );
      
      _initialized = true;
      print('Isar database initialized at: $isarPath');
    } catch (e) {
      print('Error initializing Isar database: $e');
      throw Exception('Failed to initialize Isar database: $e');
    }
  }

  Future<Word> createWord(Word word) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.words.put(word);
      });
      return word;
    } catch (e) {
      print('Error creating word: $e');
      throw Exception('Failed to create word: $e');
    }
  }

  Future<Word?> getWord(int id) async {
    try {
      return await _isar.words.get(id);
    } catch (e) {
      print('Error getting word: $e');
      return null;
    }
  }

  Future<Word?> getWordByWord(String word) async {
    try {
      return await _isar.words.where().wordEqualTo(word).findFirst();
    } catch (e) {
      print('Error getting word by word: $e');
      return null;
    }
  }

  Future<List<Word>> getWords({int? limit, int? offset}) async {
    try {
      final query = _isar.words.where().sortByFrequencyDesc();
      
      if (offset != null) {
        query.offset(offset);
      }
      if (limit != null) {
        query.limit(limit);
      }
      
      return await query.findAll();
    } catch (e) {
      print('Error getting words: $e');
      return [];
    }
  }

  Future<Word> updateWord(Word word) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.words.put(word);
      });
      return word;
    } catch (e) {
      print('Error updating word: $e');
      throw Exception('Failed to update word: $e');
    }
  }

  Future<void> deleteWord(int id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.words.delete(id);
      });
    } catch (e) {
      print('Error deleting word: $e');
      throw Exception('Failed to delete word: $e');
    }
  }

  Future<void> deleteWordByWord(String word) async {
    try {
      final wordToDelete = await getWordByWord(word);
      if (wordToDelete != null) {
        await deleteWord(wordToDelete.id);
      }
    } catch (e) {
      print('Error deleting word by word: $e');
      throw Exception('Failed to delete word by word: $e');
    }
  }

  Future<void> fillDb() async {
    try {
      await initialize();
      
      final jsonDir = Directory(Config.jsonDir);
      
      if (!await jsonDir.exists()) {
        print('JSON directory does not exist: ${Config.jsonDir}');
        return;
      }

      final jsonFiles = jsonDir.listSync().where((file) {
        return file is File && file.path.endsWith('.json');
      }).cast<File>();

      print('Found ${jsonFiles.length} JSON files to process');

      for (final jsonFile in jsonFiles) {
        try {
          final jsonContent = await jsonFile.readAsString();
          
          // Create Entry object from JSON
          final entry = Entry.fromJson(jsonContent);
          
          // Extract frequency from filename (pattern: word_frequency.json)
          final filename = path.basenameWithoutExtension(jsonFile.path);
          final frequency = _extractFrequencyFromFilename(filename);
          
          // Create Entry with frequency from filename
          final entryWithFrequency = entry.copyWith(frequency: frequency);
          
          // Check if word already exists
          final existingWord = await getWordByWord(entryWithFrequency.word);
          if (existingWord != null) {
            print('Word already exists, skipping: ${entryWithFrequency.word}');
            continue;
          }
          
          // Create Word object from Entry with frequency from filename
          final word = Word.fromEntry(entryWithFrequency);
          
          // Save to Isar
          await createWord(word);
          
          print('Successfully saved word: ${word.word} (frequency: $frequency)');
          
        } catch (e) {
          print('Error processing file ${jsonFile.path}: $e');
          continue;
        }
      }
      
      print('Database population completed successfully');
    } catch (e) {
      print('Error filling database: $e');
      throw Exception('Failed to fill database: $e');
    }
  }

  Future<void> close() async {
    try {
      if (_initialized) {
        await _isar.close();
        _initialized = false;
        print('Isar database closed');
      }
    } catch (e) {
      print('Error closing Isar database: $e');
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

// Main method for standalone script functionality
Future<void> main(List<String> arguments) async {
  final dbService = IsarDbService();
  
  try {
    print('Starting Isar database service...');
    await dbService.initialize();
    
    if (arguments.contains('--fill-db')) {
      print('Filling database from JSON files...');
      await dbService.fillDb();
      print('Database filling completed.');
    } else if (arguments.contains('--test')) {
      print('Testing database operations...');
      
      // Test basic operations
      final words = await dbService.getWords(limit: 5);
      print('Found ${words.length} words in database');
      
      if (words.isNotEmpty) {
        final firstWord = words.first;
        print('First word: ${firstWord.word}, frequency: ${firstWord.frequency}');
        
        // Test get by word
        final foundWord = await dbService.getWordByWord(firstWord.word);
        print('Retrieved word: ${foundWord?.word}');
      }
    } else {
      print('Available commands:');
      print('  --fill-db  : Fill database from JSON files');
      print('  --test     : Test database operations');
    }
    
  } catch (e) {
    print('Error: $e');
  } finally {
    await dbService.close();
    print('Database service closed.');
  }
}


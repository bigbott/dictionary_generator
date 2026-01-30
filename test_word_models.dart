import 'dart:convert';
import 'package:dictionary_generator/models/dictionary/entry.dart';
import 'package:dictionary_generator/models/appwrite/word.dart' as appwrite_word;
import 'package:dictionary_generator/models/isar/word.dart' as isar_word;

void main() {
  // Test JSON from the error case - missing forms field
  final testJson = '''
{
  "word": "all",
  "pronunciation": "/ɔːl/",
  "transliteration": "олл",
  "parts_of_speech": [
    {
      "pos": "determiner",
      "definitions": [
        {
          "meaning": "весь, вся, все",
          "example": "All the students passed the exam.",
          "example_ru": "Все студенты сдали экзамен."
        }
      ]
    },
    {
      "pos": "pronoun",
      "definitions": [
        {
          "meaning": "все",
          "example": "All of them are here.",
          "example_ru": "Все они здесь."
        }
      ]
    },
    {
      "pos": "adverb",
      "definitions": [
        {
          "meaning": "всецело, полностью",
          "example": "He was all attention.",
          "example_ru": "Он был полностью внимате"
        }
      ]
    }
  ]
}
  ''';

  try {
    print('Testing Appwrite Word model...');
    final entry = Entry.fromJson(testJson);
    final appwriteWord = appwrite_word.Word.fromEntry(entry);
    
    print('✅ Appwrite Word created successfully!');
    print('Word: ${appwriteWord.word}');
    print('Frequency: ${appwriteWord.frequency}');
    print('Meanings: ${appwriteWord.meanings}');
    print('Forms: ${appwriteWord.forms}');
    print('Parts of Speech: ${appwriteWord.partsOfSpeech}');
    
    print('\nTesting Isar Word model...');
    final isarWord = isar_word.Word.fromEntry(entry);
    
    print('✅ Isar Word created successfully!');
    print('Word: ${isarWord.word}');
    print('Frequency: ${isarWord.frequency}');
    print('Meanings: ${isarWord.meanings}');
    print('Forms: ${isarWord.forms}');
    print('Parts of Speech: ${isarWord.partsOfSpeech}');
    
    print('\n✅ All tests passed! Both Word models handle nullable forms correctly.');
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}
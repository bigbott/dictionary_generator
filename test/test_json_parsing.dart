import 'dart:convert';
import '../lib/models/dictionary/entry.dart';

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
    print('Testing JSON parsing...');
    final entry = Entry.fromJson(testJson);
    print('✅ Success! Parsed entry for word: ${entry.word}');
    print('Word: ${entry.word}');
    print('Pronunciation: ${entry.pronunciation}');
    print('Transliteration: ${entry.transliteration}');
    print('Parts of speech count: ${entry.partsOfSpeech.length}');
    
    for (var i = 0; i < entry.partsOfSpeech.length; i++) {
      final pos = entry.partsOfSpeech[i];
      print('POS ${i + 1}: ${pos.pos}');
      print('  Forms: ${pos.forms}');
      print('  Definitions count: ${pos.definitions.length}');
    }
    
    print('✅ All tests passed!');
  } catch (e, stackTrace) {
    print('❌ Error parsing JSON: $e');
    print('Stack trace: $stackTrace');
  }
}
import 'dart:convert';
import 'package:dictionary_generator/models/dictionary/entry.dart';

void main() {
  // Test JSON without frequency field (like in your error case)
  final jsonWithoutFrequency = '''
  {
    "word": "addition",
    "pronunciation": "/əˈdɪʃən/",
    "transliteration": "эди́шн",
    "parts_of_speech": [
      {
        "pos": "noun",
        "forms": {
          "singular": "addition",
          "plural": "additions"
        },
        "definitions": [
          {
            "meaning": "добавление, прибавление",
            "example": "This is a welcome addition to the team.",
            "example_ru": "Это желанное пополнение команды."
          },
          {
            "meaning": "сложение (математика)",
            "example": "The addition of 5 and 3 equals 8.",
            "example_ru": "Сложение 5 и 3 равно 8."
          }
        ]
      }
    ]
  }
  ''';

  // Test JSON with frequency field
  final jsonWithFrequency = '''
  {
    "word": "test",
    "frequency": 500,
    "pronunciation": "/test/",
    "transliteration": "тест",
    "parts_of_speech": [
      {
        "pos": "noun",
        "forms": {
          "singular": "test",
          "plural": "tests"
        },
        "definitions": [
          {
            "meaning": "тест",
            "example": "This is a test.",
            "example_ru": "Это тест."
          }
        ]
      }
    ]
  }
  ''';

  try {
    print('Testing JSON without frequency field...');
    final entry1 = Entry.fromJson(jsonWithoutFrequency);
    print('✓ Successfully parsed entry without frequency');
    print('  Word: ${entry1.word}');
    print('  Frequency: ${entry1.frequency} (should default to 1)');
    print('');

    print('Testing JSON with frequency field...');
    final entry2 = Entry.fromJson(jsonWithFrequency);
    print('✓ Successfully parsed entry with frequency');
    print('  Word: ${entry2.word}');
    print('  Frequency: ${entry2.frequency} (should be 500)');
    print('');

    print('All tests passed! The fix works correctly.');
  } catch (e) {
    print('✗ Error: $e');
  }
}
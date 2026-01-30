import 'package:dictionary_generator/models/dictionary/entry.dart';

class Word {
  final String word;
  final int frequency;
  final String json;
  final String meanings;
  final String forms;
  final List<String> partsOfSpeech;

  const Word({
    required this.word,
    required this.frequency,
    required this.json,
    required this.meanings,
    required this.forms,
    required this.partsOfSpeech,
  });

  factory Word.fromEntry(Entry entry) {
    final meaningsList = <String>[];
    final formsList = <String>[];
    final partsOfSpeechList = <String>[];

    for (final partOfSpeech in entry.partsOfSpeech) {
      partsOfSpeechList.add(partOfSpeech.pos);
      
      for (final definition in partOfSpeech.definitions) {
        meaningsList.add(definition.meaning);
      }
      
      // Handle nullable forms
      if (partOfSpeech.forms != null) {
        formsList.addAll(partOfSpeech.forms!.values);
      }
    }

    return Word(
      word: entry.word,
      frequency: entry.frequency!,
      json: entry.toJson(),
      meanings: meaningsList.join(','),
      forms: formsList.join(','),
      partsOfSpeech: partsOfSpeechList,
    );
  }

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'] as String,
      frequency: json['frequency'] as int,
      json: json['json'] as String,
      meanings: json['meanings'] as String,
      forms: json['forms'] as String,
      partsOfSpeech: List<String>.from(json['parts_of_speech'] as List),
    );
  }

}
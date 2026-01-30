import 'package:isar/isar.dart';
import 'package:dictionary_generator/models/dictionary/entry.dart';

part 'word.g.dart';

@collection
class Word {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  final String word;
  final int frequency;
  final String json;
  @Index()
  final String meanings;
  @Index()
  final String forms;
  @Index()
  final List<String> partsOfSpeech;

   Word({
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
    )..id = entry.word.hashCode;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'frequency': frequency,
      'json': json,
      'meanings': meanings,
      'forms': forms,
      'partsOfSpeech': partsOfSpeech,
    };
  }

}
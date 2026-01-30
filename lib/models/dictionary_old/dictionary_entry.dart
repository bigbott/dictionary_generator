import 'dart:convert';
import 'package:equatable/equatable.dart';

class DictionaryEntry extends Equatable {
  final String word;
  final int freaquency;
  final String translation;
  final String transcription;
  final String transliteration;
  final String partOfSpeech;
  final String example;
  final String exampleTranslation;
  final String? verbInfinitive;
   final String? verbSecondForm;
  final String? verbFirstForm;
  final String? verbThirdForm;

  const DictionaryEntry({
    required this.word,
    required this.freaquency,
    required this.translation,
    required this.transcription,
    required this.transliteration,
    required this.partOfSpeech,
    required this.example,
    required this.exampleTranslation,
    this.verbInfinitive,
    this.verbFirstForm,
    this.verbSecondForm,
    this.verbThirdForm,
  });

  factory DictionaryEntry.fromJson(String str) =>
      DictionaryEntry.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DictionaryEntry.fromMap(Map<String, dynamic> json) => DictionaryEntry(
        word: json['word'],
        freaquency: json['freaquency'],
        translation: json['translation'],
        transcription: json['transcription'],
        transliteration: json['transliteration'],
        partOfSpeech: json['partOfSpeech'],
        example: json['example'],
        exampleTranslation: json['exampleTranslation'],
        verbInfinitive: json['verbInfinitive'],
        verbFirstForm: json['verbFirstForm'],
        verbSecondForm: json['verbSecondForm'],
        verbThirdForm: json['verbThirdForm'],
      );

  Map<String, dynamic> toMap() => {
        'word': word,
        'freaquency': freaquency,
        'translation': translation,
        'transcription': transcription,
        'transliteration': transliteration,
        'partOfSpeech': partOfSpeech,
        'example': example,
        'exampleTranslation': exampleTranslation,
        'verbInfinitive': verbInfinitive,
        'verbFirstForm': verbFirstForm,
        'verbSecondForm': verbSecondForm,
        'verbThirdForm': verbThirdForm,
      };

  DictionaryEntry copyWith({
    String? word,
    int? freaquency,
    String? translation,
    String? transcription,
    String? transliteration,
    String? partOfSpeech,
    String? example,
    String? exampleTranslation,
    String? verbInfinitive,
    String? verbFirstForm,
    String? verbSecondForm,
    String? verbThirdForm,
  }) =>
      DictionaryEntry(
        word: word ?? this.word,
        freaquency: freaquency ?? this.freaquency,
        translation: translation ?? this.translation,
        transcription: transcription ?? this.transcription,
        transliteration: transliteration ?? this.transliteration,
        partOfSpeech: partOfSpeech ?? this.partOfSpeech,
        example: example ?? this.example,
        exampleTranslation: exampleTranslation ?? this.exampleTranslation,
        verbInfinitive: verbInfinitive ?? this.verbInfinitive,
        verbFirstForm: verbFirstForm ?? this.verbFirstForm,
        verbSecondForm: verbSecondForm ?? this.verbSecondForm,
        verbThirdForm: verbThirdForm ?? this.verbThirdForm,
      );

  @override
  List<Object?> get props => [
        word,
        freaquency,
        translation,
        transcription,
        transliteration,
        partOfSpeech,
        example,
        exampleTranslation,
        verbInfinitive,
        verbFirstForm,
        verbSecondForm,
        verbThirdForm,
      ];
}

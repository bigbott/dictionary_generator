import 'package:equatable/equatable.dart';
import 'dart:convert';
import 'part_of_speech.dart';

class Entry extends Equatable {
  final String word;
  final int? frequency;
  final String pronunciation;
  final String transliteration;
  final List<PartOfSpeech> partsOfSpeech;

  const Entry({
    required this.word,
    this.frequency = 1,
    required this.pronunciation,
    required this.transliteration,
    required this.partsOfSpeech,
  });

  @override
  List<Object?> get props => [word, frequency, pronunciation, transliteration, partsOfSpeech];

  Entry copyWith({
    String? word,
    int? frequency,
    String? pronunciation,
    String? transliteration,
    List<PartOfSpeech>? partsOfSpeech,
  }) {
    return Entry(
      word: word ?? this.word,
      frequency: frequency ?? this.frequency,
      pronunciation: pronunciation ?? this.pronunciation,
      transliteration: transliteration ?? this.transliteration,
      partsOfSpeech: partsOfSpeech ?? this.partsOfSpeech,
    );
  }

  factory Entry.fromJson(String str) {
    return Entry.fromMap(json.decode(str));
  }

  String toJson() {
    return json.encode(toMap());
  }

  factory Entry.fromMap(Map<String, dynamic> json) {
    return Entry(
      word: json['word'] as String,
      frequency: json['frequency'] as int? ?? 1,
      pronunciation: json['pronunciation'] as String,
      transliteration: json['transliteration'] as String,
      partsOfSpeech: (json['parts_of_speech'] as List)
          .map((partOfSpeech) => PartOfSpeech.fromMap(Map<String, dynamic>.from(partOfSpeech as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'frequency': frequency,
      'pronunciation': pronunciation,
      'transliteration': transliteration,
      'parts_of_speech': partsOfSpeech.map((partOfSpeech) => partOfSpeech.toMap()).toList(),
    };
  }
}
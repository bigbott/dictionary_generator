import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:dictionary_generator/models/dictionary_old/dictionary_entry.dart';

class Dictionary extends Equatable {
  final List<DictionaryEntry> entries;

  const Dictionary({required this.entries});

  factory Dictionary.fromJson(String str) => Dictionary.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Dictionary.fromMap(Map<String, dynamic> json) => Dictionary(
        entries: List<DictionaryEntry>.from(
            json['entries'].map((x) => DictionaryEntry.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        'entries': List<dynamic>.from(entries.map((x) => x.toMap())),
      };

  Dictionary copyWith({List<DictionaryEntry>? entries}) =>
      Dictionary(entries: entries ?? this.entries);

  @override
  List<Object?> get props => [entries];
}

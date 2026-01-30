import 'package:equatable/equatable.dart';
import 'definition.dart';

class PartOfSpeech extends Equatable {
  final String pos;
  final Map<String, String>? forms;
  final List<Definition> definitions;

  const PartOfSpeech({
    required this.pos,
    this.forms,
    required this.definitions,
  });

  @override
  List<Object?> get props => [pos, forms, definitions];

  PartOfSpeech copyWith({
    String? pos,
    Map<String, String>? forms,
    List<Definition>? definitions,
  }) {
    return PartOfSpeech(
      pos: pos ?? this.pos,
      forms: forms ?? this.forms,
      definitions: definitions ?? this.definitions,
    );
  }

  factory PartOfSpeech.fromJson(String str) {
    return PartOfSpeech.fromMap(Map<String, dynamic>.from(
      Map<String, dynamic>.from(str as dynamic),
    ));
  }

  String toJson() {
    return toMap().toString();
  }

  factory PartOfSpeech.fromMap(Map<String, dynamic> json) {
    return PartOfSpeech(
      pos: json['pos'] as String,
      forms: json['forms'] != null ? Map<String, String>.from(json['forms'] as Map) : null,
      definitions: (json['definitions'] as List)
          .map((definition) => Definition.fromMap(Map<String, dynamic>.from(definition as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pos': pos,
      'forms': forms,
      'definitions': definitions.map((definition) => definition.toMap()).toList(),
    };
  }
}
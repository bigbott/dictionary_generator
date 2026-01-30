import 'package:equatable/equatable.dart';

class Definition extends Equatable {
  final String meaning;
  final String example;
  final String exampleRu;

  const Definition({
    required this.meaning,
    required this.example,
    required this.exampleRu,
  });

  @override
  List<Object?> get props => [meaning, example, exampleRu];

  Definition copyWith({
    String? meaning,
    String? example,
    String? exampleRu,
  }) {
    return Definition(
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      exampleRu: exampleRu ?? this.exampleRu,
    );
  }

  factory Definition.fromJson(String str) {
    return Definition.fromMap(Map<String, dynamic>.from(
      Map<String, dynamic>.from(str as dynamic),
    ));
  }

  String toJson() {
    return toMap().toString();
  }

  factory Definition.fromMap(Map<String, dynamic> json) {
    return Definition(
      meaning: json['meaning'] as String,
      example: json['example'] as String,
      exampleRu: json['example_ru'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'meaning': meaning,
      'example': example,
      'example_ru': exampleRu,
    };
  }
}
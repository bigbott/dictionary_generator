import 'dart:convert';

class Review {
    final String id;
    final String text;

    Review({
        required this.id,
        required this.text,
    });

    Review copyWith({
        String? id,
        String? text,
    }) => 
        Review(
            id: id ?? this.id,
            text: text ?? this.text,
        );

    factory Review.fromJson(String str) => Review.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Review.fromMap(Map<String, dynamic> json) => Review(
        id: json["id"],
        text: json["text"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "text": text,
    };
}

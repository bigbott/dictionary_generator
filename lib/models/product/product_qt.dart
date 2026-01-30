
import 'package:dictionary_generator/models/product/review_qt.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

class Product {
    final String id;
    final List<Review> reviews;
    final Map<String, String> similarProducts;

    Product({
        required this.id,
        required this.reviews,
        required this.similarProducts,
    });

    Product copyWith({
        String? id,
        List<Review>? reviews,
        Map<String, String>? similarProducts,
    }) => 
        Product(
            id: id ?? this.id,
            reviews: reviews ?? this.reviews,
            similarProducts: similarProducts ?? this.similarProducts,
        );

    factory Product.fromJson(String str) => Product.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Product.fromMap(Map<String, dynamic> json) => Product(
        id: json["id"],
        reviews: List<Review>.from(json["reviews"].map((x) => Review.fromMap(x))),
        similarProducts: Map.from(json["similarProducts"]).map((k, v) => MapEntry<String, String>(k, v)),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "reviews": List<dynamic>.from(reviews.map((x) => x.toMap())),
        "similarProducts": Map.from(similarProducts).map((k, v) => MapEntry<String, dynamic>(k, v)),
    };
}
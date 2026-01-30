import 'package:equatable/equatable.dart';
import 'dart:convert';
import 'review.dart';

class Product extends Equatable {
  final String id;
  final List<Review> reviews;
  final Map<String, String> similarProducts;

  const Product({
    required this.id,
    required this.reviews,
    required this.similarProducts,
  });

  Product copyWith({
    String? id,
    List<Review>? reviews,
    Map<String, String>? similarProducts,
  }) {
    return Product(
      id: id ?? this.id,
      reviews: reviews ?? this.reviews,
      similarProducts: similarProducts ?? this.similarProducts,
    );
  }

  factory Product.fromJson(String str) => Product.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        id: json["id"],
        reviews: List<Review>.from(json["reviews"].map((x) => Review.fromMap(x))),
        similarProducts: Map<String, String>.from(json["similarProducts"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "reviews": List<dynamic>.from(reviews.map((x) => x.toMap())),
        "similarProducts": similarProducts,
      };

  @override
  List<Object?> get props => [id, reviews, similarProducts];
}
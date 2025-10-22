class Location {
  final String id;
  final String name;
  final String province;
  final String? description;
  final double? rating;
  final int? reviewCount;
  final String? imageUrl;

  Location({
    required this.id,
    required this.name,
    required this.province,
    this.description,
    this.rating,
    this.reviewCount,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'province': province,
    'description': description,
    'rating': rating,
    'reviewCount': reviewCount,
    'imageUrl': imageUrl,
  };

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    id: json['id'],
    name: json['name'],
    province: json['province'],
    description: json['description'],
    rating: (json['rating'] ?? 0).toDouble(),
    reviewCount: json['reviewCount'] ?? 0,
    imageUrl: json['imageUrl'],
  );
}

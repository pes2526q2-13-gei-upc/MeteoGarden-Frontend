class SeedOption {
  final String scientificName;
  final int amount;
  final String? imageUrl;

  const SeedOption({
    required this.scientificName,
    required this.amount,
    this.imageUrl,
  });

  factory SeedOption.fromJson(Map<String, dynamic> json) {
    return SeedOption(
      scientificName: json['scientificName'],
      amount: json['amount'],
      imageUrl: json['image_url'] as String?,
    );
  }
}

class ProductItem {
  final String productName;
  final int amount;
  final String? imageUrl;
  final String? description;

  ProductItem({
    required this.productName,
    required this.amount,
    this.imageUrl,
    this.description,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      productName: json['productName'] as String,
      amount: json['amount'] as int,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }
}

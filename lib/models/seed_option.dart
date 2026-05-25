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
  final String displayName;
  final int amount;
  final String? imageUrl;
  final String? description;

  ProductItem({
    required this.productName,
    required this.displayName,
    required this.amount,
    this.imageUrl,
    this.description,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    final internalName =
        (json['productName'] ?? json['product_name'] ?? json['name'] ?? '')
            .toString();

    return ProductItem(
      productName: internalName,
      displayName: (json['displayName'] ?? json['display_name'] ?? internalName)
          .toString(),
      amount: json['amount'] ?? 0,
      imageUrl: json['image_url'],
      description: json['description'],
    );
  }
}

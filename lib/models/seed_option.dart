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

  ProductItem({required this.productName, required this.amount, this.imageUrl});

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
    productName: json['productName'],
    amount: json['amount'],
    imageUrl: json['image_url'] as String?,
  );
}

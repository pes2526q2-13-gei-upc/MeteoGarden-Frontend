class SeedOption {
  final String scientificName;
  final int amount;

  const SeedOption({required this.scientificName, required this.amount});

  factory SeedOption.fromJson(Map<String, dynamic> json) {
    return SeedOption(
      scientificName: json['scientificName'],
      amount: json['amount'],
    );
  }
}

class ProductItem {
  final String productName;
  final int amount;

  ProductItem({required this.productName, required this.amount});

  factory ProductItem.fromJson(Map<String, dynamic> json) =>
      ProductItem(productName: json['productName'], amount: json['amount']);
}

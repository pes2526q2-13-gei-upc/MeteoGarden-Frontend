class SeedOption {
  final String scientificName;
  final int amount;

  const SeedOption({
    required this.scientificName,
    required this.amount,
  });

  factory SeedOption.fromJson(Map<String, dynamic> json) {
    return SeedOption(
      scientificName: json['scientific_name'],
      amount: json['amount'],
    );
  }
}
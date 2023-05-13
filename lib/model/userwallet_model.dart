class Currency {
  final String cryptoName;
  final Map<String, num> conversionRate;
  late final num available;

  Currency({
    required this.cryptoName,
    required this.conversionRate,
    required this.available,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      cryptoName: json['cryptoName'],
      conversionRate: Map<String, num>.from(json['conversionRate']),
      available: json['available'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cryptoName': cryptoName,
      'conversionRate': conversionRate,
      'available': available,
    };
  }
}

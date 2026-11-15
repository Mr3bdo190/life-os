class Subscription {
  final String id;
  String name;
  double amount;
  DateTime nextBillingDate;
  bool isActive;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.nextBillingDate,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'nextBillingDate': nextBillingDate.toIso8601String(),
        'isActive': isActive,
      };

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'],
        name: json['name'],
        amount: (json['amount'] as num).toDouble(),
        nextBillingDate: DateTime.parse(json['nextBillingDate']),
        isActive: json['isActive'] ?? true,
      );
}

class BudgetItem {
  final String id;
  String title;
  double amount;
  bool isExpense;
  final DateTime date;

  BudgetItem({
    required this.id,
    required this.title,
    required this.amount,
    this.isExpense = true,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'isExpense': isExpense,
        'date': date.toIso8601String(),
      };

  factory BudgetItem.fromJson(Map<String, dynamic> json) => BudgetItem(
        id: json['id'],
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        isExpense: json['isExpense'] ?? true,
        date: DateTime.parse(json['date']),
      );
}

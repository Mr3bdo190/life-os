class Habit {
  final String id;
  String title;
  List<String> completedDates; // بنحفظ التواريخ بصيغة YYYY-MM-DD
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.title,
    this.completedDates = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completedDates': completedDates,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'],
        title: json['title'],
        completedDates: List<String>.from(json['completedDates'] ?? []),
        createdAt: DateTime.parse(json['createdAt']),
      );
}

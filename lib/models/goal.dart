class Goal {
  final String id;
  String title;
  double progress; // من 0 لـ 100
  bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    this.progress = 0.0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'progress': progress,
        'isCompleted': isCompleted,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'],
        title: json['title'],
        progress: (json['progress'] as num).toDouble(),
        isCompleted: json['isCompleted'] ?? false,
      );
}

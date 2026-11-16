class Task {
  final String id;
  String title;
  bool done;
  int priority; // 0=Low, 1=Medium, 2=High
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.done = false,
    this.priority = 1,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'priority': priority,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        done: json['done'] ?? false,
        priority: json['priority'] ?? 1,
        createdAt: DateTime.parse(json['createdAt']),
      );
}

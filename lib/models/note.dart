class Note {
  final String id;
  String title;
  String body;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    this.body = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        body: json['body'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
      );
}

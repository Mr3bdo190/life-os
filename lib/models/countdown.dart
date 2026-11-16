class CountdownEvent {
  final String id;
  String title;
  DateTime targetDate;
  CountdownEvent({required this.id, required this.title, required this.targetDate});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'targetDate': targetDate.toIso8601String()};
  factory CountdownEvent.fromJson(Map<String, dynamic> json) => CountdownEvent(id: json['id'], title: json['title'], targetDate: DateTime.parse(json['targetDate']));
}

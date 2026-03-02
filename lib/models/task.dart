
class Task {
  final int? id;
  final String title;
  final bool isDone;
  final String createdAt; // Stored as ISO8601 string (YYYY-MM-DD)

  Task({
    this.id,
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] == 1,
      createdAt: map['createdAt'],
    );
  }

  Task copyWith({
    int? id,
    String? title,
    bool? isDone,
    String? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

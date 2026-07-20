class Subtask {
  int? id;
  int taskId; // foreign key ke tabel tasks
  String title;
  String status;

  Subtask({
    this.id,
    required this.taskId, // foreign key ke tabel tasks
    required this.title,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'taskId': taskId, 'title': title, 'status': status};
  }

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'],
      taskId: map['taskId'],
      title: map['title'],
      status: map['status'],
    );
  }
}

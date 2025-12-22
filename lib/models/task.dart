class Task {
  int? id;
  int userId; // foreign key ke tabel users
  String title;
  String description;
  String category;
  String status;
  String date;
  double latitude;
  double longitude;

  Task({
    this.id,
    required this.userId, // foreign key ke tabel users
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.date,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'date': date,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      status: map['status'],
      date: map['date'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

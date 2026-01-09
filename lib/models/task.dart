class Task {
  int? id;
  int userId;
  String title;
  String description;
  String category;
  String status;

  String createdAt;
  String? deadline;

  double? latitude;
  double? longitude;

  Task({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.deadline,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'createdAt': createdAt,
      'deadline': deadline,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Task copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? category,
    String? status,
    String? createdAt,
    String? deadline,
    double? latitude,
    double? longitude,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      status: map['status'],
      createdAt: map['createdAt'],
      deadline: map['deadline'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

// Pastikan file ini ada di folder lib/data/

class Task {
  final String title;
  final String description;
  final String category;
  final DateTime? deadline;
  String status;
  
  // --- FIELD BARU UNTUK MAPS ---
  final double? latitude;
  final double? longitude;

  Task({
    required this.title,
    required this.description,
    required this.category,
    this.deadline,
    required this.status,
    // Tambahkan ini di constructor
    this.latitude,
    this.longitude,
  });
}

// Data Dummy Global
List<Task> globalTasks = [
  Task(
    title: 'Meeting Klien',
    description: 'Presentasi proyek baru',
    category: 'Kantor',
    deadline: DateTime.now(),
    status: 'pending',
    // Lokasi Dummy (Monas)
    latitude: -6.175392,
    longitude: 106.827153,
  ),
  Task(
    title: 'Belanja Barang',
    description: 'Beli ATK kantor',
    category: 'Logistik',
    deadline: DateTime.now().add(Duration(days: 1)),
    status: 'checklist',
    // Lokasi Dummy (Bundaran HI)
    latitude: -6.194957,
    longitude: 106.823026,
  ),
];
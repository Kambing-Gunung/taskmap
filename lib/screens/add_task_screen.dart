import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // Import untuk tipe data LatLng
import 'location_picker_screen.dart';   // Import halaman picker yang baru dibuat

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  String _selectedStatus = 'pending'; 
  DateTime? _selectedDate; 
  
  // Variabel baru untuk menyimpan Lokasi
  LatLng? _selectedLocation;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi Baru: Membuka Halaman Peta untuk Pilih Lokasi
  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPickerScreen()),
    );

    // Jika user menekan tombol centang dan membawa data balik
    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Judul tidak boleh kosong!')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon pilih deadline tugas!')),
      );
      return;
    }

    Navigator.pop(context, {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _categoryController.text.isEmpty ? 'Umum' : _categoryController.text,
      'status': _selectedStatus,
      'deadline': _selectedDate,
      // Kirim data Latitude & Longitude (bisa null jika tidak dipilih)
      'latitude': _selectedLocation?.latitude,
      'longitude': _selectedLocation?.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    String dateText = _selectedDate == null 
        ? 'Pilih Deadline' 
        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";

    // Text untuk menampilkan koordinat yang dipilih
    String locationText = _selectedLocation == null
        ? 'Pilih Lokasi di Peta'
        : "Lokasi: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}";

    return Scaffold(
      appBar: AppBar(title: Text('Tambah Task Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Tugas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            SizedBox(height: 16),
            
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),

            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            SizedBox(height: 24),

            // --- INPUT DEADLINE ---
            Text("Deadline Tugas:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateText, style: TextStyle(fontSize: 16)),
                    Icon(Icons.calendar_month, color: Colors.blue),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // --- INPUT LOKASI (BARU) ---
            Text("Lokasi Tugas:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            InkWell(
              onTap: _pickLocation, // Buka Peta
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        locationText, 
                        style: TextStyle(
                          fontSize: 16,
                          // Ubah warna teks jadi biru jika sudah pilih lokasi
                          color: _selectedLocation != null ? Colors.blue[800] : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.map, color: Colors.red),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // --- INPUT STATUS ---
            Text("Pilih Status Awal:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                _buildStatusOption('pending', Icons.access_time, Colors.orange, "Pending"),
                SizedBox(width: 8),
                _buildStatusOption('checklist', Icons.check_circle, Colors.green, "Selesai"),
                SizedBox(width: 8),
                _buildStatusOption('batal', Icons.cancel, Colors.red, "Batal"),
              ],
            ),
            SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Simpan Task', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk tombol status agar kodenya lebih rapi
  Widget _buildStatusOption(String value, IconData icon, MaterialColor color, String label) {
    bool isSelected = _selectedStatus == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.shade100 : Colors.grey.shade100,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: 4),
              Text(label, style: TextStyle(color: color[800], fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
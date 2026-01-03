import 'package:flutter/material.dart';
import '/data/task.dart';

class DetailTaskScreen extends StatelessWidget {
  final Task task;

  // Menerima data task dari halaman sebelumnya
  const DetailTaskScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // Format tanggal deadline
    String deadlineText = task.deadline != null
        ? "${task.deadline!.day}-${task.deadline!.month}-${task.deadline!.year}"
        : "Tidak ada deadline";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Judul & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(task.status),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Informasi Kategori
            Row(
              children: [
                const Icon(Icons.category, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "Kategori: ${task.category}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 3. Informasi Deadline
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "Deadline: $deadlineText",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 4. Informasi Lokasi (Jika ada)
            if (task.latitude != null && task.longitude != null)
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Lokasi: ${task.latitude}, ${task.longitude}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            
            const Divider(height: 40),

            // 5. Deskripsi
            const Text(
              "Deskripsi:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                task.description.isEmpty ? "Tidak ada deskripsi." : task.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget kecil untuk menampilkan status berwarna
  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    String label;

    if (status == 'checklist') {
      color = Colors.green;
      icon = Icons.check_circle;
      label = "Selesai";
    } else if (status == 'batal') {
      color = Colors.red;
      icon = Icons.cancel;
      label = "Batal";
    } else {
      color = Colors.orange;
      icon = Icons.access_time;
      label = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
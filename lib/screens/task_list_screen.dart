import 'package:flutter/material.dart';
import '/widgets/bottom_nav.dart';
import '/data/task.dart';
import 'add_task_screen.dart';
import 'detail_task_screen.dart'; // <--- IMPORT FILE BARU

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task List')),
      body: globalTasks.isEmpty
          ? const Center(child: Text('Belum ada tugas. Tambahkan sekarang!'))
          : ListView.builder(
              itemCount: globalTasks.length,
              itemBuilder: (context, index) {
                final task = globalTasks[index];
                
                // --- Logika Tampilan Ikon ---
                IconData statusIcon;
                Color statusColor;
                if (task.status == 'checklist') {
                  statusIcon = Icons.check_circle;
                  statusColor = Colors.green;
                } else if (task.status == 'batal') {
                  statusIcon = Icons.cancel;
                  statusColor = Colors.red;
                } else {
                  statusIcon = Icons.access_time; 
                  statusColor = Colors.orange;
                }
                
                String deadlineText = task.deadline != null 
                    ? "${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}"
                    : 'Tanpa Deadline';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    // A. KLIK IKON: Untuk Mengubah Status (Cepat)
                    leading: IconButton(
                      icon: Icon(statusIcon, color: statusColor, size: 32),
                      onPressed: () {
                        setState(() {
                          if (task.status == 'pending') task.status = 'checklist';
                          else if (task.status == 'checklist') task.status = 'batal';
                          else task.status = 'pending';
                        });
                      },
                    ),
                    
                    title: Text(
                      task.title, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: task.status != 'pending' ? TextDecoration.lineThrough : null,
                        color: task.status != 'pending' ? Colors.grey : Colors.black,
                      )
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.description, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis // Agar tidak terlalu panjang di list
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(deadlineText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                    
                    // B. KLIK BADAN LIST: Membuka Halaman Detail
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailTaskScreen(task: task),
                        ),
                      ).then((_) {
                        // Refresh halaman list saat kembali (siapa tahu status berubah)
                        setState(() {});
                      });
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );

          if (result != null) {
            setState(() {
              globalTasks.add(Task(
                title: result['title'],
                description: result['description'],
                category: result['category'],
                deadline: result['deadline'],
                status: result['status'],
                latitude: result['latitude'], // Pastikan field ini ada di AddTaskScreen jika sudah ditambahkan
                longitude: result['longitude'],
              ));
            });
          }
        },
      ),
      bottomNavigationBar: BottomNav(currentIndex: 0),
    );
  }
}
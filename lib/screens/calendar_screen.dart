import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '/widgets/bottom_nav.dart';
import '/data/task.dart'; // IMPORT PENTING

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // Fungsi untuk mengambil task berdasarkan hari tertentu
  List<Task> _getTasksForDay(DateTime day) {
    return globalTasks.where((task) {
      // Cek apakah tanggal deadline sama dengan tanggal kalender
      return task.deadline != null && isSameDay(task.deadline, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil daftar task untuk tanggal yang sedang dipilih
    List<Task> selectedTasks = _getTasksForDay(_selectedDay!);

    return Scaffold(
      appBar: AppBar(title: Text('Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            
            // Logika Penanda (Titik di bawah tanggal)
            eventLoader: _getTasksForDay, 
            
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            
            // Sedikit styling agar penanda terlihat jelas
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          Divider(),
          
          // Header List
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Tugas Tanggal: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Menampilkan List Tugas (Filtered)
          Expanded(
            child: selectedTasks.isEmpty
                ? Center(child: Text("Tidak ada tugas di tanggal ini."))
                : ListView.builder(
                    itemCount: selectedTasks.length,
                    itemBuilder: (context, index) {
                      final task = selectedTasks[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Icon(Icons.access_time, color: Colors.orange),
                          title: Text(task.title),
                          subtitle: Text(task.category),
                          trailing: task.status == 'checklist' 
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: 1),
    );
  }
}
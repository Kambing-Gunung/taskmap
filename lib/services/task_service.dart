import 'database_service.dart';
import '../models/task.dart';

// Entity Task
// Menyimpan data task aplikasi TaskMap
class TaskService {
  final _dbService = DatabaseService();

  // INSERT
  Future<int> insertTask(Task task) async {
    final db = await _dbService.database;
    return await db.insert('tasks', task.toMap());
  }

  // GET ALL
  Future<List<Task>> getTasks() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // UPDATE
  Future<int> updateTask(Task task) async {
    final db = await _dbService.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // DELETE
  Future<int> deleteTask(int id) async {
    final db = await _dbService.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}

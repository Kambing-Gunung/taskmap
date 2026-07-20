import 'database_service.dart';
import '../models/subtask.dart';

// Entity Subtask
// Menyimpan data subtask aplikasi TaskMap
class SubtaskService {
  final _dbService = DatabaseService();

  // INSERT
  Future<int> insertSubtask(Subtask subtask) async {
    final db = await _dbService.database;
    return await db.insert('subtasks', subtask.toMap());
  }

  // GET ALL
  Future<List<Subtask>> getSubtasks() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('subtasks');

    return maps.map((map) => Subtask.fromMap(map)).toList();
  }

  // UPDATE
  Future<int> updateSubtask(Subtask subtask) async {
    final db = await _dbService.database;
    return await db.update(
      'subtasks',
      subtask.toMap(),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  // DELETE
  Future<int> deleteSubtask(int id) async {
    final db = await _dbService.database;
    return await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }
}

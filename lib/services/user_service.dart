import 'database_service.dart';
import '../models/user.dart';

// Entity User
// Menyimpan data user aplikasi TaskMap
class UserService {
  final _dbService = DatabaseService();

  // INSERT
  Future<int> insertUser(User user) async {
    final db = await _dbService.database;
    return await db.insert('users', user.toMap());
  }

  // GET ALL
  Future<List<User>> getUsers() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return maps.map((map) => User.fromMap(map)).toList();
  }

  // GET USER BY EMAIL / USERNAME
  Future<User?> getUserByEmail(String email) async {
    final db = await _dbService.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // UPDATE
  Future<int> updateUser(User user) async {
    final db = await _dbService.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // DELETE
  Future<int> deleteUser(int id) async {
    final db = await _dbService.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}

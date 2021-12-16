import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute(
      'CREATE TABLE items('
      'id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      'title TEXT, '
      'description TEXT, '
      'created_at TIMESTAMP NOT NULL DEFAUL CURRENT_TIMESMAP'
      ')',
    );
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'todo.db',
      version: 1,
      onCreate: (
        sql.Database database,
        int version,
      ) async {
        await createTables(database);
      },
    );
  }

  static Future<int> insertItem(String title, String? description) async {
    final db = await SqlHelper.db();
    final data = {'title': title, 'description': description};
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<Map<String, dynamic>>> readAllItem() async {
    final db = await SqlHelper.db();

    return db.query('itens', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> readByIdItem(int id) async {
    final db = await SqlHelper.db();

    return db.query('itens', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
      int id, String title, String? description) async {
    final db = await SqlHelper.db();
    final data = {
      'title': title,
      'description': description,
      'created_at': DateTime.now().toString(),
    };

    final result = await db.update(
      'items',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );

    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SqlHelper.db();
    try {
      await db.delete(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (err) {
      debugPrint('Erro ao deletar o item: $err');
    }
  }
}

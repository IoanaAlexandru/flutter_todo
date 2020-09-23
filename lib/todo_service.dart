import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do/todo.dart';

class ToDoService with ChangeNotifier {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableTodo ( 
  $columnId integer primary key autoincrement, 
  $columnTitle text not null,
  $columnDone integer not null)
''');
    });
  }

  addTodo(ToDo todo) async {
    todo.id = await db.insert(tableTodo, todo.toMap());
    notifyListeners();
  }

  Future<List<ToDo>> get todos async {
    List<Map> maps =
        await db.query(tableTodo, columns: [columnId, columnDone, columnTitle]);
    return maps.map((m) => ToDo.fromMap(m)).toList();
  }

  Future<int> update(ToDo todo) async {
    return await db.update(tableTodo, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }
}

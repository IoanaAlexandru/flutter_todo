import 'package:flutter/material.dart';
import 'package:to_do/todo.dart';

class ToDoService with ChangeNotifier {
  List<ToDo> todos = [
    ToDo(content: 'Feed the dog'),
    ToDo(content: 'Walk the cat', done: true)
  ];

  addTodo(ToDo todo) {
    todos.add(todo);
    notifyListeners();
  }
}

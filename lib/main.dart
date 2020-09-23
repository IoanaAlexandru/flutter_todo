import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do/todo.dart';
import 'package:to_do/todo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ToDoService service = ToDoService();
  await service.open('todo.db');
  runApp(ChangeNotifierProvider(create: (_) => service, child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.pink,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'My TODOs'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          future: Provider.of<ToDoService>(context).todos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<ToDo> todos = snapshot.data ?? [];
              return TodoList(initialTodos: todos);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => AddTodoPage())),
        tooltip: 'Add todo',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TodoList extends StatefulWidget {
  final List<ToDo> initialTodos;

  const TodoList({Key key, this.initialTodos}) : super(key: key);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<ToDo> todos;

  @override
  void initState() {
    super.initState();
    todos = widget.initialTodos;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, i) => Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: todos[i].done,
              title: Text(
                todos[i].title,
                style: todos[i].done
                    ? TextStyle(decoration: TextDecoration.lineThrough)
                    : TextStyle(),
              ),
              onChanged: (newValue) {
                setState(() => todos[i].done = newValue);
                Provider.of<ToDoService>(context).update(todos[i]);
              },
            ),
          ),
          if (todos[i].done)
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () =>
                    Provider.of<ToDoService>(context, listen: false)
                        .delete(todos[i].id)),
        ],
      ),
    );
  }
}

class AddTodoPage extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new TODO'),
        actions: [
          FlatButton(
            onPressed: () {
              Provider.of<ToDoService>(context, listen: false)
                  .addTodo(ToDo(title: controller.text));
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(labelText: 'TODO'),
            ),
          ),
          Image.asset('assets/todo.png'),
        ],
      ),
    );
  }
}

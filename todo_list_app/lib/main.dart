import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        hintColor: Colors.orange),
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> todos = List<String>.empty(growable: true);
  String input = "";

  createTodos() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(input);

    // Map
    Map<String, String> todos = {"todosTitle": input};
    documentReference.set(todos).whenComplete(() => "$input created");
  }

  deleteTodos() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("myTodos"),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    title: Text("Add Todolist"),
                    content: TextField(onChanged: (String value) {
                      input = value;
                    }),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            createTodos();
                            Navigator.of(context).pop();
                          },
                          child: Text("Add")),
                    ],
                  );
                });
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          )),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("MyTodos").snapshots(),
        builder: (context, snapshots) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshots.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot documentSnapshot = snapshots.data!.docs[index];
              return Dismissible(
                key: Key(index.toString()),
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    // Use the correct field name here (todosTitle instead of todoTitle)
                    title: Text(documentSnapshot["todosTitle"]),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          // Also, you should update the list in your setState
                          // to avoid inconsistencies with your data.
                          todos.removeAt(index);
                        });
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

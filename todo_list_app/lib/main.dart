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
  String input = "";

  createTodos() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(input);

    // Map
    Map<String, String> todos = {"todosTitle": input}; // Correct the field name to "todosTitle"
    documentReference.set(todos).whenComplete(() => "$input created");
  }

  deleteTodos(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(item);
    documentReference.delete().whenComplete(() => "$item deleted");
  }

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
                  borderRadius: BorderRadius.circular(8),
                ),
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
                    child: Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("MyTodos").snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshots.hasError) {
            return Text('Error: ${snapshots.error}');
          }

          QuerySnapshot<Map<String, dynamic>> querySnapshot = snapshots.data!;
          List<DocumentSnapshot<Map<String, dynamic>>> documents =
              querySnapshot.docs;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                  documents[index];
              return Dismissible(
                onDismissed: (direction) {
                  deleteTodos(documentSnapshot["todosTitle"]);
                },
                key: Key(documentSnapshot["todosTitle"]),
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(documentSnapshot["todosTitle"]),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          deleteTodos(documentSnapshot["todosTitle"]);
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/todo.dart';

const String todoCollectionRef = "<your-ref>";
const String userCollectionRef = "<your-ref>";

class ToDoDataBase {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _todosRef;

  ToDoDataBase() {
    final String uid = getLoggedInUserId();

    _todosRef = _firestore
        .collection(userCollectionRef)
        .doc(uid)
        .collection(todoCollectionRef)
        .withConverter<Todo>(
            fromFirestore: (snapshots, _) => Todo.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (todo, _) => todo.toJson());
  }

  String getLoggedInUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return "";
    }
  }

  Stream<QuerySnapshot> getTodos() {
    final String uid = getLoggedInUserId();
    return _firestore
        .collection(userCollectionRef)
        .doc(uid)
        .collection(todoCollectionRef)
        .snapshots();
  }

  void addTodo(Todo todo) {
    _todosRef.add(todo);
  }

  void updateTodo(String todoId, Todo todo) {
    _todosRef.doc(todoId).update(todo.toJson());
  }

  void deleteTodo(String todoId) {
    _todosRef.doc(todoId).delete();
  }
}

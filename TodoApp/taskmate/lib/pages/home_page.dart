import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:taskmate/components/snack_message.dart';
import 'package:taskmate/components/toast_message.dart';
import 'package:taskmate/pages/empty_page.dart';
import 'package:taskmate/pages/no_signal_page.dart';
import 'package:taskmate/service/auth_service.dart';
import 'package:taskmate/widgets/about_module.dart';

import '../model/todo.dart';
import '../service/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskAddingController = TextEditingController();

  final ToDoDataBase _databaseService = ToDoDataBase();
  final ToastMessage callToast = const ToastMessage();
  final SnackMessage callSnack = SnackMessage();
  final AboutModule callDescription = const AboutModule();
  final UserAuthentication uAuth = UserAuthentication();
  late String? userMail = '';
  late String? firstChar = '';
  StreamSubscription? subscription;
  late bool isConnected = true;

  notifyDone() {
    callToast.showToast(context,
        message: 'Mark as done', icon: Icons.check_circle_outlined);
  }

  notifyDoneRefresh() {
    callToast.showToast(context,
        message: 'Updated', icon: Icons.cloud_done_outlined);
  }

  notifyunDone() {
    callToast.showToast(context, message: 'Mark as undone', icon: Icons.block);
  }

  throwSuccess() {
    callSnack.showSnack(context, 'Task added', null);
  }

  throwDelete() {
    callSnack.showSnack(context, 'Task removed', null);
  }

  throwEmptyException() {
    callSnack.showSnack(context, 'Empty task discarded', null);
  }

  throwNetworkException() {
    callSnack.showSnack(
        context, 'No internet connection available', Icons.cloud_off);
  }

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      setState(() {
        isConnected = result.contains(ConnectivityResult.none) ? false : true;
      });
    });
    if (isConnected == true) {
      _getAccountInfo();
    }
  }

  void checkNetworkOnCRUD() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      setState(() {
        isConnected = result.contains(ConnectivityResult.none) ? false : true;
      });
    });
  }

  Future<void> _handleSignOut() async {
    await uAuth.signOut(context);
  }

  void _getAccountInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userMail = user.email;
        firstChar = userMail![0].toUpperCase();
      });
    } else {
      callToast.showToast(context,
          message: 'Couldn\'t fetch email', icon: Icons.cloud_done_outlined);
    }
  }

  void showPopupMenu(BuildContext context) async {
    final Size screenSize = MediaQuery.of(context).size;
    final String? selected = await showMenu<String>(
        context: context,
        position:
            RelativeRect.fromLTRB(screenSize.width, 84, 0, screenSize.height),
        items: <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            child: const Row(
              children: [
                Icon(Icons.account_circle_outlined),
                SizedBox(width: 8),
                Text('My Account')
              ],
            ),
            onTap: () {
              showBottomSheet(context);
            },
          ),
          PopupMenuItem<String>(
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded),
                SizedBox(width: 8),
                Text('About')
              ],
            ),
            onTap: () async {
              await showDialog(
                  context: context, builder: (context) => const AboutModule());
            },
          )
        ]);

    if (selected == null) {
      return;
    }
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (BuildContext context) {
        return Container(
          width: 340,
          margin: const EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 8),
              const Text('Account Information',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                      overflow: TextOverflow.ellipsis, maxLines: 1, userMail!),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(left: 30, right: 30),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    onPressed: () {
                      Navigator.pop(context);
                      _handleSignOut();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.power_settings_new_outlined,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    )),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(),
      body: _buildUI(),
      floatingActionButton: Visibility(
          visible: isConnected,
          child: FloatingActionButton(
            onPressed: _displayTextInputDialog,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          )),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80.0),
                bottomRight: Radius.circular(80.0))),
        toolbarHeight: 70,
        elevation: 0.0,
        actions: [
          Visibility(
            visible: isConnected,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  showPopupMenu(context);
                },
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: Text(firstChar!),
                ),
              ),
            ),
          )
        ],
        title: Text('TaskMate',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorLight)));
  }

  Widget _buildUI() {
    return Visibility(
      visible: true,
      child:
          isConnected ? SafeArea(child: _messagesListView()) : const NoSignal(),
    );
  }

  Widget _messagesListView() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _databaseService.getTodos();
        });
        notifyDoneRefresh();
      },
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.80,
        width: MediaQuery.sizeOf(context).width,
        child: StreamBuilder(
          stream: _databaseService.getTodos(),
          builder: (context, snapshot) {
            List todos = snapshot.data?.docs ?? [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (todos.isEmpty) {
              return const EmptyPage();
            } else {
              return ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> todoMap = todos[index].data();
                  Todo todo = Todo.fromJson(todoMap);
                  String todoId = todos[index].id;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Theme.of(context).primaryColorLight,
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.0),
                        onLongPress: () async {
                          await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: const Text("Deletion"),
                                    content: const Text(
                                      'Do you want to delete selected task ?',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    actions: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                checkNetworkOnCRUD();
                                                Navigator.pop(context);
                                                if (isConnected == false) {
                                                  throwNetworkException();
                                                } else {
                                                  _databaseService
                                                      .deleteTodo(todoId);
                                                  throwDelete();
                                                }
                                              },
                                              child: const Text('Yes')),
                                          const SizedBox(width: 6),
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('No')),
                                        ],
                                      )
                                    ],
                                  ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      todo.task,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          decoration: !todo.isDone
                                              ? TextDecoration.none
                                              : TextDecoration.lineThrough),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      DateFormat("dd-MM-yyyy h:mm a").format(
                                        todo.updatedOn.toDate(),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Checkbox(
                                value: todo.isDone,
                                onChanged: (value) {
                                  checkNetworkOnCRUD();
                                  if (isConnected == false) {
                                    throwNetworkException();
                                  } else {
                                    Todo updatedTodo = todo.copyWith(
                                      isDone: !todo.isDone,
                                      updatedOn: Timestamp.now(),
                                    );
                                    _databaseService.updateTodo(
                                        todoId, updatedTodo);
                                    if (todo.isDone) {
                                      notifyunDone();
                                    } else {
                                      notifyDone();
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  void _displayTextInputDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.post_add_outlined),
              SizedBox(width: 8),
              Text('Add Todo'),
            ],
          ),
          content: TextField(
            keyboardType: TextInputType.text,
            controller: _taskAddingController,
            maxLength: 20,
            autofocus: true,
            cursorOpacityAnimates: true,
            decoration: InputDecoration(
                hintText: 'Type a new todo',
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 1.6)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                fillColor: HexColor('#c8bce4').withOpacity(0.7),
                filled: true,
                prefixIcon: const Icon(Icons.edit)),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    onPressed: () {
                      Todo todo = Todo(
                          task: _taskAddingController.text,
                          isDone: false,
                          createdOn: Timestamp.now(),
                          updatedOn: Timestamp.now());
                      if (_taskAddingController.text.isEmpty) {
                        Navigator.pop(context);
                        throwEmptyException();
                      } else {
                        checkNetworkOnCRUD();
                        if (isConnected == false) {
                          Navigator.pop(context);
                          throwNetworkException();
                          _taskAddingController.clear();
                        } else {
                          Navigator.pop(context);
                          _databaseService.addTodo(todo);
                          _taskAddingController.clear();
                          throwSuccess();
                        }
                      }
                    },
                    child: const Text('Save',
                        style: TextStyle(color: Colors.white))),
                const SizedBox(width: 6),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    onPressed: () {
                      Navigator.pop(context);
                      _taskAddingController.clear();
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white))),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    subscription?.cancel();
    _taskAddingController.dispose();
    super.dispose();
  }
}

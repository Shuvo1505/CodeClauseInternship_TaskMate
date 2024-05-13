import 'package:flutter/material.dart';

class AboutModule extends StatefulWidget {
  const AboutModule({super.key});

  @override
  State<StatefulWidget> createState() => AboutPageState();
}

class AboutPageState extends State<AboutModule> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        icon: Image.asset(
          "assets/images/app_icon.png",
          width: 60,
          height: 60,
          color: Theme.of(context).primaryColor,
        ),
        title: const Text("About TaskMate"),
        content: const Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0),
          child: Text(
            "TaskMate is a sophisticated and intuitive "
            "task management application designed "
            "to streamline your daily productivity. "
            "With TaskMaster, you can effortlessly "
            "organize your tasks, prioritize your "
            "to-dos, and stay focused on what "
            "matters most.\n\n"
            "Developer: Purnendu Guha",
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.start,
          ),
        ),
        actions: [
          TextButton(
              child: const Text("Dismiss"),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
        elevation: 24,
        backgroundColor: Colors.white);
  }
}

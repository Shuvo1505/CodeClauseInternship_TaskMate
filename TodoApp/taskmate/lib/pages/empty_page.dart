import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/app_icon.png',
            width: 60,
            height: 60,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 12),
          const Text('Nothing to show here !',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Try to add some new task.',
              style: TextStyle(
                  fontSize: 16, color: Theme.of(context).disabledColor))
        ],
      ),
    );
  }
}

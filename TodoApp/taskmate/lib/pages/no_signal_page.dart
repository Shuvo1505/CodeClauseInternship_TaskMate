import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoSignal extends StatelessWidget {
  const NoSignal({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_network.png',
            width: 60,
            height: 60,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 12),
          const Text('You\'re Offline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Please connect to the internet',
              style: TextStyle(
                  fontSize: 16, color: Theme.of(context).disabledColor)),
          Text('and restart the app',
              style: TextStyle(
                  fontSize: 16, color: Theme.of(context).disabledColor)),
          const SizedBox(height: 10),
          SizedBox(
            width: 120,
            child: ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text('Close')),
          )
        ],
      ),
    );
  }
}

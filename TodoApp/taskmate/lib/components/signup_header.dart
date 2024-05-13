import 'package:flutter/material.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/app_icon.png',
                height: 50, width: 50, color: Theme.of(context).primaryColor),
            Text(
              "Hello, there!",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
            Text(
              "Create your new account",
              style: TextStyle(color: Theme.of(context).primaryColor),
            )
          ],
        )
      ],
    );
  }
}

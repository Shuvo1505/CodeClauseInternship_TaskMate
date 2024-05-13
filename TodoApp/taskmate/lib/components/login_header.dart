import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

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
              "Welcome Back",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
            Text(
              "Enter your credentials to login",
              style: TextStyle(color: Theme.of(context).primaryColor),
            )
          ],
        ),
      ],
    );
  }
}

class SigninHeader extends StatelessWidget {
  const SigninHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 1,
              color: Theme.of(context).primaryColor),
        ),
        Text(
          "Other Sign In Option",
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
        ),
        Expanded(
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 1,
              color: Theme.of(context).primaryColor),
        ),
      ],
    );
  }
}

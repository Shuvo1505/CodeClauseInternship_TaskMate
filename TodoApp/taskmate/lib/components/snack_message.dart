import 'package:flutter/material.dart';

class SnackMessage {
  void showSnack(BuildContext context, String message, IconData? icon) {
    late bool changeSnack = false;
    if (icon != null) {
      changeSnack = true;
    }
    SnackBar snackbar;
    snackbar = SnackBar(
        content: Row(
          children: [
            Visibility(
              visible: changeSnack,
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            Visibility(visible: changeSnack, child: const SizedBox(width: 10)),
            Text(message,
                style: const TextStyle(fontSize: 16.0, color: Colors.white)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}

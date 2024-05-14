import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmate/pages/login_page.dart';

import '../components/toast_message.dart';
import '../pages/home_page.dart';

class UserAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ToastMessage callToast = const ToastMessage();
  final storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<void> googleSignIn(BuildContext context) async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount?.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication?.accessToken,
        idToken: googleSignInAuthentication?.idToken,
      );
      if (googleSignInAccount != null) {
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        if (context.mounted) {
          storeToken(userCredential);
          callToast.showToast(context,
              message: 'Login successful', icon: Icons.check_circle_outlined);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (builder) => const HomePage()),
              (route) => false);
        }
      } else {
        if (context.mounted) {
          callToast.showToast(context,
              message: 'Couldn\'t authenticate', icon: Icons.warning_amber);
        }
      }
    } catch (e) {
      if (context.mounted) {
        callToast.showToast(context,
            message: 'Couldn\'t authenticate', icon: Icons.warning_amber);
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await storage.delete(key: "token");
      await storage.delete(key: 'uid');
      await storage.delete(key: 'loguid');
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) => const LoginPage()),
            (route) => false);
        callToast.showToast(context,
            message: 'Signed out', icon: Icons.power_settings_new_outlined);
      }
    } catch (e) {
      if (context.mounted) {
        callToast.showToast(context,
            message: 'Sign out was unsuccessful', icon: Icons.warning_amber);
      }
    }
  }

  Future<void> storeToken(UserCredential userCredential) async {
    await storage.write(
        key: "", value: userCredential.credential?.token.toString());
    await storage.write(key: "", value: userCredential.toString());
  }

  Future<String?> getToken() async {
    return await storage.read(key: "");
  }
}

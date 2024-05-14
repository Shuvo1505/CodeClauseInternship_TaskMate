import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:taskmate/components/signup_header.dart';
import 'package:taskmate/components/snack_message.dart';

import '../components/toast_message.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<SignupPage> {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  late bool circularProgress = false;
  late bool activeLogin = true;
  late bool activeSignUp = true;
  final TextEditingController _passwordEditingController =
      TextEditingController();
  final TextEditingController _confirmPasswordEditingController =
      TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final ToastMessage callToast = const ToastMessage();
  final SnackMessage callSnack = SnackMessage();
  final storage = const FlutterSecureStorage();
  late bool _isPasswordVisible = false;
  late bool _isConfirmPasswordVisible = false;

  notifyEmptyError() {
    callToast.showToast(context,
        message: 'Field/s can\'t be empty', icon: Icons.warning_amber);
  }

  notifyPasswordMismatchError() {
    callToast.showToast(context,
        message: 'Confirmation password didn\'t match',
        icon: Icons.warning_amber);
  }

  notifyPasswordLengthError() {
    callToast.showToast(context,
        message: 'Password must be at least of 8 characters',
        icon: Icons.warning_amber);
  }

  notifyPasswordSecurityError() {
    callToast.showToast(context,
        message: 'Weak password', icon: Icons.warning_amber);
  }

  notifyInvalidEmailError() {
    callToast.showToast(context,
        message: 'Email address is not valid', icon: Icons.warning_amber);
  }

  notifyDuplicateUserError() {
    callToast.showToast(context,
        message: 'User already exists', icon: Icons.warning_amber);
  }

  notifyServerException() {
    callToast.showToast(context,
        message: 'Something went wrong', icon: Icons.warning_amber);
  }

  notifyPositiveServerResponse() {
    callToast.showToast(context,
        message: 'Account created successfully',
        icon: Icons.check_circle_outlined);
  }

  void _revokeFocus() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _pushUserToCloud() async {
    setState(() {
      circularProgress = true;
      activeSignUp = false;
      activeLogin = false;
    });
    try {
      firebase_auth.UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
              email: _emailEditingController.text,
              password: _passwordEditingController.text);
      notifyPositiveServerResponse();
      await storage.write(key: '<your-key>', value: userCredential.user!.uid);
      setState(() {
        circularProgress = false;
        activeLogin = true;
        activeSignUp = true;
      });
      _passwordEditingController.clear();
      _emailEditingController.clear();
      _confirmPasswordEditingController.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) => const HomePage()),
            (route) => false);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        notifyDuplicateUserError();
        setState(() {
          circularProgress = false;
          activeLogin = true;
          activeSignUp = true;
          _passwordEditingController.clear();
          _emailEditingController.clear();
          _confirmPasswordEditingController.clear();
        });
      } else {
        notifyServerException();
        setState(() {
          circularProgress = false;
          activeLogin = true;
          activeSignUp = true;
          _passwordEditingController.clear();
          _emailEditingController.clear();
          _confirmPasswordEditingController.clear();
        });
      }
    }
  }

  void _signUpUserAction() {
    RegExp strongPassRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');
    RegExp emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (_emailEditingController.text.isEmpty ||
        _passwordEditingController.text.isEmpty ||
        _confirmPasswordEditingController.text.isEmpty) {
      notifyEmptyError();
    } else if (_passwordEditingController.text !=
        _confirmPasswordEditingController.text) {
      notifyPasswordMismatchError();
    } else if (_passwordEditingController.text.length < 8) {
      notifyPasswordLengthError();
    } else if (!strongPassRegex.hasMatch(_passwordEditingController.text)) {
      notifyPasswordSecurityError();
    } else if (!emailRegex.hasMatch(_emailEditingController.text)) {
      notifyInvalidEmailError();
    } else {
      _pushUserToCloud();
    }
  }

  Widget _signUp(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
            onPressed: activeSignUp
                ? () {
                    _revokeFocus();
                    _signUpUserAction();
                  }
                : null,
            style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 10),
                disabledBackgroundColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).primaryColor),
            child: !circularProgress
                ? const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 29,
                        height: 29,
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      SizedBox(width: 14),
                      Text(
                        "Creating account...",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  )),
        const SizedBox(height: 14),
        Container(
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: activeLogin
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, 1)),
            ],
          ),
          child: TextButton(
            onPressed: activeLogin
                ? () {
                    Navigator.pop(context);
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    color: activeLogin
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                    Icons.arrow_back_outlined),
                const SizedBox(width: 8),
                Text(
                  "Back to login",
                  style: TextStyle(
                    fontSize: 16,
                    color: activeLogin
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height - 60,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Column(
                  children: <Widget>[SignupHeader()],
                ),
                Column(
                  children: <Widget>[
                    TextField(
                      controller: _emailEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          hintText: 'Email address',
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.6)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                          fillColor: HexColor('#c8bce4').withOpacity(0.7),
                          filled: true,
                          prefixIcon: const Icon(Icons.email_outlined)),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordEditingController,
                      decoration: InputDecoration(
                        hintText: "Password",
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1.6)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        fillColor: HexColor('#c8bce4').withOpacity(0.7),
                        filled: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _confirmPasswordEditingController,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1.6)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        fillColor: HexColor('#c8bce4').withOpacity(0.7),
                        filled: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isConfirmPasswordVisible,
                    ),
                    const SizedBox(height: 30),
                    _signUp(context)
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailEditingController.dispose();
    _passwordEditingController.dispose();
    _confirmPasswordEditingController.dispose();
    super.dispose();
  }
}

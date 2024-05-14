import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:taskmate/components/login_header.dart';
import 'package:taskmate/components/toast_message.dart';
import 'package:taskmate/pages/forgot_password.dart';
import 'package:taskmate/pages/home_page.dart';
import 'package:taskmate/pages/signup_page.dart';
import 'package:taskmate/service/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final ToastMessage callToast = const ToastMessage();
  final UserAuthentication userAuth = UserAuthentication();
  late bool circularProgress = false;
  late bool activeLogin = true;
  late bool activeOauth = true;
  late bool activePassword = true;
  final TextEditingController _passwordEditingController =
      TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final storage = const FlutterSecureStorage();
  late bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _inputField(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  notifyInvalidEmailError() {
    callToast.showToast(context,
        message: 'Email address is not valid', icon: Icons.warning_amber);
  }

  notifyUserNullError() {
    callToast.showToast(context,
        message: 'User doesn\'t exist', icon: Icons.warning_amber);
  }

  notifyWrongCredentialError() {
    callToast.showToast(context,
        message: 'Wrong email or password', icon: Icons.warning_amber);
  }

  notifyEmptyError() {
    callToast.showToast(context,
        message: 'Field/s can\'t be empty', icon: Icons.warning_amber);
  }

  notifyServerException() {
    callToast.showToast(context,
        message: 'Something went wrong', icon: Icons.warning_amber);
  }

  notifyPositiveServerResponse() {
    callToast.showToast(context,
        message: 'Login successful', icon: Icons.check_circle_outlined);
  }

  void _redirectSignupPage(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SignupPage()));
  }

  void _revokeFocus() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _pullUserFromCloud() async {
    setState(() {
      circularProgress = true;
      activeLogin = false;
      activeOauth = false;
      activePassword = false;
    });
    try {
      firebase_auth.UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
              email: _emailEditingController.text,
              password: _passwordEditingController.text);
      notifyPositiveServerResponse();
      await storage.write(key: '<your-key>', value: userCredential.user!.uid);
      setState(() {
        circularProgress = false;
        activeLogin = true;
        activeOauth = true;
        activePassword = true;
      });
      _passwordEditingController.clear();
      _emailEditingController.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) => const HomePage()),
            (route) => false);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        notifyWrongCredentialError();
        setState(() {
          circularProgress = false;
          activeLogin = true;
          activeOauth = true;
          activePassword = true;
          _passwordEditingController.clear();
          _emailEditingController.clear();
        });
      } else {
        notifyServerException();
        setState(() {
          circularProgress = false;
          activeLogin = true;
          activeOauth = true;
          activePassword = true;
          _passwordEditingController.clear();
          _emailEditingController.clear();
        });
      }
    }
  }

  Future<void> _forceGoogleAuthentication() async {
    setState(() {
      circularProgress = true;
      activeLogin = false;
      activeOauth = false;
      activePassword = false;
    });
    await userAuth.googleSignIn(context);
    setState(() {
      circularProgress = false;
      activeLogin = true;
      activeOauth = true;
      activePassword = true;
    });
  }

  void _loginUserAction() {
    RegExp emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (_emailEditingController.text.isEmpty ||
        _passwordEditingController.text.isEmpty) {
      notifyEmptyError();
    } else if (!emailRegex.hasMatch(_emailEditingController.text)) {
      notifyInvalidEmailError();
    } else {
      _pullUserFromCloud();
    }
  }

  Widget _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LoginHeader(),
        const SizedBox(height: 70),
        TextField(
          controller: _emailEditingController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              hintText: 'Email address',
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 1.6)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              fillColor: HexColor('#c8bce4').withOpacity(0.7),
              filled: true,
              prefixIcon: const Icon(Icons.email_outlined)),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordEditingController,
          decoration: InputDecoration(
            hintText: "Password",
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColor, width: 1.6)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            fillColor: HexColor('#c8bce4').withOpacity(0.7),
            filled: true,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isPasswordVisible,
        ),
        _forgotPassword(context),
        const SizedBox(height: 30),
        _login(context),
      ],
    );
  }

  Widget _forgotPassword(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: activePassword
              ? () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPassword()));
                }
              : null,
          child: Text(
            "Forgot password ?",
            style: TextStyle(
                color: activePassword
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
                fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _login(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
            onPressed: activeLogin
                ? () {
                    _revokeFocus();
                    _loginUserAction();
                  }
                : null,
            style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 10),
                backgroundColor: Theme.of(context).primaryColor,
                disabledBackgroundColor: Theme.of(context).primaryColor),
            child: activeLogin
                ? const Text(
                    "Sign In",
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
                        "Wait a moment...",
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
              color: activeOauth
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
            onPressed: activeOauth
                ? () {
                    _redirectSignupPage(context);
                  }
                : null,
            child: Text(
              "Create Account",
              style: TextStyle(
                fontSize: 16,
                color: activeOauth
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 34),
        const SigninHeader(),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: activeOauth
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
                onPressed: activeOauth
                    ? () {
                        _forceGoogleAuthentication();
                      }
                    : null,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/google.png',
                      color: activeLogin
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).disabledColor,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      "Continue With Google",
                      style: TextStyle(
                        fontSize: 16,
                        color: activeOauth
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    _passwordEditingController.dispose();
    _emailEditingController.dispose();
    super.dispose();
  }
}

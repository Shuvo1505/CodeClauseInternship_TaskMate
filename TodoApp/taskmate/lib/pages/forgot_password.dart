import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:taskmate/components/toast_message.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<StatefulWidget> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late bool activeSend = true;
  final ToastMessage callToast = const ToastMessage();
  late bool circularProgress = false;
  final TextEditingController _emailEditingController = TextEditingController();

  notifyEmptyError() {
    callToast.showToast(context,
        message: 'Field/s can\'t be empty', icon: Icons.warning_amber);
  }

  notifyUserNullError() {
    callToast.showToast(context,
        message: 'Something went wrong', icon: Icons.warning_amber);
  }

  notifyPositiveServerResponse() {
    callToast.showToast(context,
        message: 'Password reset link sent', icon: Icons.check_circle_outlined);
  }

  notifyInvalidEmailError() {
    callToast.showToast(context,
        message: 'Email address is not valid', icon: Icons.warning_amber);
  }

  void _revokeFocus() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _sendPasswordResetLink() async {
    setState(() {
      circularProgress = true;
      activeSend = false;
    });
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailEditingController.text.trim());
      notifyPositiveServerResponse();
      setState(() {
        circularProgress = false;
        activeSend = true;
      });
    } catch (e) {
      notifyUserNullError();
      setState(() {
        circularProgress = false;
        activeSend = true;
      });
    }
  }

  void _forgotPasswordAction() {
    RegExp emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (_emailEditingController.text.isEmpty) {
      notifyEmptyError();
      _emailEditingController.clear();
    } else if (!emailRegex.hasMatch(_emailEditingController.text)) {
      notifyInvalidEmailError();
      _emailEditingController.clear();
    } else {
      _sendPasswordResetLink();
      _emailEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height - 10,
          margin: const EdgeInsets.only(top: 50),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _inputField(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/app_icon.png',
                    height: 50,
                    width: 50,
                    color: Theme.of(context).primaryColor),
                Text(
                  "Forgot Password",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor),
                ),
                Text(
                  "We will send you an email with a link to reset \nyour password, "
                  "Please enter the email \nassociated to your account below.",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),
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
        const SizedBox(height: 30),
        _forgotPass(context),
      ],
    );
  }

  Widget _forgotPass(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
            onPressed: activeSend
                ? () {
                    _revokeFocus();
                    _forgotPasswordAction();
                  }
                : null,
            style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 10),
                backgroundColor: Theme.of(context).primaryColor,
                disabledBackgroundColor: Theme.of(context).primaryColor),
            child: !circularProgress
                ? const Text(
                    "Send Link",
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
                        "Verifying...",
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
              color: activeSend
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
            onPressed: activeSend
                ? () {
                    Navigator.pop(context);
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    color: activeSend
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                    Icons.arrow_back_outlined),
                const SizedBox(width: 8),
                Text(
                  "Back to login",
                  style: TextStyle(
                    fontSize: 16,
                    color: activeSend
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
  void dispose() {
    _emailEditingController.dispose();
    super.dispose();
  }
}

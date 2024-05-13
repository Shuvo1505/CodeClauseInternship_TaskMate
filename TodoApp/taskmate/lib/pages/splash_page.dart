import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskmate/pages/home_page.dart';
import 'package:taskmate/pages/login_page.dart';
import 'package:taskmate/service/auth_service.dart';

void main() {
  runApp(const SplashScreen());
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final UserAuthentication userAuth = UserAuthentication();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSplash(context);
  }

  void _loadSplash(BuildContext context) async {
    String? token = await userAuth.getToken();
    String? uid = await storage.read(key: 'uid');
    String? loguid = await storage.read(key: 'loguid');
    if (token != null) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(_createHomeRoute());
      }
    } else if (uid != null) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(_createHomeRoute());
      }
    } else if (loguid != null) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(_createHomeRoute());
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(_createLoginRoute());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: SizedBox(height: 300),
                          ),
                          Center(
                              child: Image.asset("assets/images/app_icon.png",
                                  height: 70,
                                  width: 70,
                                  color: Theme.of(context).primaryColor)),
                          const SizedBox(height: 20),
                          const Center(
                              child: Text(
                            'TaskMate',
                            style: TextStyle(fontSize: 20),
                          )),
                          const SizedBox(height: 8),
                          const Center(
                            child: SizedBox(
                              width: 70,
                              child: LinearProgressIndicator(),
                            ),
                          )
                        ])))));
  }

  Route _createHomeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _createLoginRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

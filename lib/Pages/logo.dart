import 'package:flutter/material.dart';
import 'package:expensetracker/Pages/loginpage.dart'; // Ensure you import your login page

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  _LogoScreenState createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 5), () {
        _navigateToLogin();
      });
    });
  }

  void _navigateToLogin() {
    if (!_hasNavigated) {
      _hasNavigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _navigateToLogin,
        child: SizedBox.expand(
          child: Image.asset(
            'assets/images/money.png',
            fit: BoxFit.cover, // Ensures the image covers the entire screen
          ),
        ),
      ),
    );
  }
}

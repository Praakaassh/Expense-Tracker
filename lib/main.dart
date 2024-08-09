import 'dart:async';

import 'package:flutter/material.dart';
import 'package:expensetracker/Pages/logo.dart'; // Import the splash screen

void main() {
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    print('Uncaught error: $error');
    print('Stack trace: $stackTrace');
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LogoScreen(), // Set SplashScreen as the initial route
    );
  }
}

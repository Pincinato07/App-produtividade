import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(FocuslyApp());
}

class FocuslyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focusly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Sans',
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

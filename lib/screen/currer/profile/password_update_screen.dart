import 'package:flutter/material.dart';
class PasswordUpdateScreen extends StatefulWidget {
  const PasswordUpdateScreen({super.key});

  @override
  State<PasswordUpdateScreen> createState() => _PasswordUpdateScreenState();
}

class _PasswordUpdateScreenState extends State<PasswordUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text("Password Update"),
      ),
    );
  }
}

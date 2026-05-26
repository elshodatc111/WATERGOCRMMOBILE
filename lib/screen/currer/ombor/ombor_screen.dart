import 'package:flutter/material.dart';
class OmborScreen extends StatefulWidget {
  const OmborScreen({super.key});

  @override
  State<OmborScreen> createState() => _OmborScreenState();
}

class _OmborScreenState extends State<OmborScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text("Ombor"),
      ),
    );
  }
}

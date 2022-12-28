import 'package:flutter/material.dart';

class CallingPage extends StatefulWidget {
  const CallingPage({super.key});

  @override
  State<CallingPage> createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calling Page'),
        backgroundColor: const Color.fromARGB(255, 104, 54, 3),
      ),
      body: _buildCallingPageBody(),
    );
  }

  Widget _buildCallingPageBody() {
    return SingleChildScrollView();
  }
}

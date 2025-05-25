import 'package:flutter/material.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Home'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Doctor Home Screen',
        ),
      ),
    );
  }
}

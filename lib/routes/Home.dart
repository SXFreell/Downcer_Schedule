import 'package:downcer/widgets/index.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return  const Scaffold(
      backgroundColor: Color(0xFFf9f9f9),
      body: Schedule(),
    );
  }
}
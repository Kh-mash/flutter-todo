import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo',
      home: const Scaffold(
        body: Center(child: Text('Phase 1 MVP')),
      ),
    );
  }
}

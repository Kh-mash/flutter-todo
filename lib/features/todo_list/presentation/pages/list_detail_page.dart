import 'package:flutter/material.dart';

class ListDetailPage extends StatelessWidget {
  const ListDetailPage({super.key, required this.listId});
  final String listId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Detail'),
      ),
      body: const Center(
        child: Text('Task list will be implemented with TaskListBloc'),
      ),
    );
  }
}

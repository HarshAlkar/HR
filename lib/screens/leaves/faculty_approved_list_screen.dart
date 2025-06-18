import 'package:flutter/material.dart';
import '../app_drawer.dart';

class FacultyApprovedListScreen extends StatefulWidget {
  const FacultyApprovedListScreen({super.key});

  @override
  State<FacultyApprovedListScreen> createState() =>
      _FacultyApprovedListScreenState();
}

class _FacultyApprovedListScreenState extends State<FacultyApprovedListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approved Leaves'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Approved Leaves List'),
      ),
    );
  }
}

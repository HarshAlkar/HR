import 'package:flutter/material.dart';
import '../app_drawer.dart';

class ParticularFacultyReportScreen extends StatefulWidget {
  const ParticularFacultyReportScreen({super.key});

  @override
  State<ParticularFacultyReportScreen> createState() =>
      _ParticularFacultyReportScreenState();
}

class _ParticularFacultyReportScreenState
    extends State<ParticularFacultyReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Particular Faculty Report'),
        backgroundColor: const Color(0xFF2A1070),
        foregroundColor: Colors.white,
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
        child: Text(
          'Particular Faculty Report Screen Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

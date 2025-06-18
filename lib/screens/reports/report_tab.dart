import 'package:flutter/material.dart';
import 'package:hr/screens/reports/combined_report_screen.dart';
import 'package:hr/screens/reports/particular_report_screen.dart';
import 'package:hr/screens/app_drawer.dart';

class ReportTab extends StatelessWidget {
  const ReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // final isSmallScreen = constraints.maxWidth < 600; // This variable is not used in the provided code

          return Scaffold(
            appBar: AppBar(
              title: const Text('Reports'),
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
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Combined Reports'),
                  Tab(text: 'Faculty Report'),
                ],
                labelColor: Colors.white,
                indicatorColor: Colors.amber,
              ),
            ),
            drawer: const AppDrawer(),
            body: const TabBarView(
              children: [CombinedReportScreen(), ParticularReportScreen()],
            ),
          );
        },
      ),
    );
  }
}

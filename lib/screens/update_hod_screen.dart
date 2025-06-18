import 'package:flutter/material.dart';

class UpdateHODScreen extends StatelessWidget {
  const UpdateHODScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    final List<Map<String, String>> hodList = [
      {
        'department': 'Computer Science',
        'current_hod': 'Dr. Alice Sharma',
        'new_hod': 'Dr. Raj Patel',
      },
      {
        'department': 'Mathematics',
        'current_hod': 'Dr. Sunita Rao',
        'new_hod': 'Dr. Priya Singh',
      },
      {
        'department': 'Physics',
        'current_hod': 'Dr. Mohan Das',
        'new_hod': 'Dr. Anil Kapoor',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update HOD'),
        backgroundColor: const Color(0xFF2A1070),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Head of Department',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DataTable(
                    columns: const [
                      DataColumn(
                          label: Text('Department',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Current HOD',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('New HOD',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Update',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: hodList.map((hod) {
                      return DataRow(
                        cells: [
                          DataCell(Text(hod['department'] ?? '')),
                          DataCell(Text(hod['current_hod'] ?? '')),
                          DataCell(Text(hod['new_hod'] ?? '')),
                          DataCell(
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                              ),
                              onPressed: () {
                                // Implement update logic
                              },
                              child: const Text('Update'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

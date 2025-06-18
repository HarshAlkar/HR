import 'package:flutter/material.dart';
import '../app_drawer.dart';
import 'package:hr/services/api_service.dart';
import 'dart:convert'; // Required for json decoding
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class CombinedReportScreen extends StatefulWidget {
  const CombinedReportScreen({super.key});

  @override
  State<CombinedReportScreen> createState() => _CombinedReportScreenState();
}

class _CombinedReportScreenState extends State<CombinedReportScreen> {
  // Monthly report dates
  DateTime? monthlyFromDate;
  DateTime? monthlyToDate;

  // Daily report date
  DateTime? dailySelectedDate;

  final TextEditingController searchController = TextEditingController();

  List<Map<String, String>> reportData = []; // Empty initially

  bool _showMonthlyReport = false; // False means show daily report initially

  List<Map<String, dynamic>> _allFaculties =
      []; // To store all fetched faculties
  List<Map<String, dynamic>> _filteredFaculties =
      []; // For autocomplete display
  String?
      _selectedFacultyNameForSearch; // To store the selected faculty name for filtering report data

  @override
  void initState() {
    super.initState();
    _loadAllFacultyNames();
  }

  Future<void> _loadAllFacultyNames() async {
    try {
      final response = await ApiService.fetchAllFacultyIds();
      if (response['facultylist'] != null) {
        setState(() {
          _allFaculties =
              List<Map<String, dynamic>>.from(response['facultylist']);
          _filteredFaculties = _allFaculties;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading faculty names for search: $e')),
      );
    }
  }

  void _filterReportDataByFaculty(String query) {
    setState(() {
      _selectedFacultyNameForSearch = query;
      // Implement filtering logic for reportData here if needed based on the search query
      // For now, this just updates the selected name for the Autocomplete.
      // Actual reportData filtering would depend on how reportData is structured and displayed.
    });
  }

  void _toggleReportView() {
    setState(() {
      _showMonthlyReport = !_showMonthlyReport;
      // Clear report data when switching view
      reportData = [];
    });
  }

  Future<void> _pickDate(BuildContext context,
      {required Function(DateTime) onDateSelected}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  void _generateDailyReport() async {
    if (dailySelectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }

    final formattedDate =
        "${dailySelectedDate!.year}-${dailySelectedDate!.month.toString().padLeft(2, '0')}-${dailySelectedDate!.day.toString().padLeft(2, '0')}";

    try {
      final response =
          await ApiService.getDailyAttendanceReport(fromDate: formattedDate);
      setState(() {
        // Assuming the API response is a list of maps, adjust if necessary
        if (response['status'] == true && response['data'] != null) {
          // Map the API response to the format expected by your DataTable
          reportData = (response['data'] as List)
              .map((item) => {
                    "date": item['date'].toString(),
                    "id": item['faculty_id'].toString(),
                    "name": item['faculty_name'].toString(),
                    "dept": item['department'].toString(),
                    "in": item['punch_in'].toString(),
                    "out": item['punch_out'].toString(),
                    "hrs": item['working_hours'].toString(),
                    "ontime": item['on_time'].toString(),
                    "remark": item['remark'].toString(),
                  })
              .toList();
        } else {
          reportData = [];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'No data found.')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load daily report: $e')),
      );
      setState(() {
        reportData = [];
      });
    }
  }

  void _generateMonthlyReport() async {
    if (monthlyFromDate == null || monthlyToDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both start and end dates.')),
      );
      return;
    }

    final formattedStartDate =
        "${monthlyFromDate!.year}-${monthlyFromDate!.month.toString().padLeft(2, '0')}-${monthlyFromDate!.day.toString().padLeft(2, '0')}";
    final formattedEndDate =
        "${monthlyToDate!.year}-${monthlyToDate!.month.toString().padLeft(2, '0')}-${monthlyToDate!.day.toString().padLeft(2, '0')}";

    try {
      final response = await ApiService.getMonthlyAttendanceReport(
          startDate: formattedStartDate, endDate: formattedEndDate);
      setState(() {
        // Assuming the API response is a list of maps, adjust if necessary
        if (response['status'] == true && response['data'] != null) {
          reportData = (response['data'] as List)
              .map((item) => {
                    "date": item['date'].toString(),
                    "id": item['faculty_id'].toString(),
                    "name": item['faculty_name'].toString(),
                    "dept": item['department'].toString(),
                    "in": item['punch_in'].toString(),
                    "out": item['punch_out'].toString(),
                    "hrs": item['working_hours'].toString(),
                    "ontime": item['on_time'].toString(),
                    "remark": item['remark'].toString(),
                  })
              .toList();
        } else {
          reportData = [];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'No data found.')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load monthly report: $e')),
      );
      setState(() {
        reportData = [];
      });
    }
  }

  void _generateWorkingHoursReport() async {
    if (monthlyFromDate == null || monthlyToDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both start and end dates.')),
      );
      return;
    }

    final formattedStartDate =
        "${monthlyFromDate!.year}-${monthlyFromDate!.month.toString().padLeft(2, '0')}-${monthlyFromDate!.day.toString().padLeft(2, '0')}";
    final formattedEndDate =
        "${monthlyToDate!.year}-${monthlyToDate!.month.toString().padLeft(2, '0')}-${monthlyToDate!.day.toString().padLeft(2, '0')}";

    try {
      final response = await ApiService.getWorkingHoursReport(
          startDate: formattedStartDate, endDate: formattedEndDate);
      setState(() {
        // Assuming the API response is a list of maps, adjust if necessary
        if (response['status'] == true && response['data'] != null) {
          reportData = (response['data'] as List)
              .map((item) => {
                    "date": item['date'].toString(),
                    "id": item['faculty_id'].toString(),
                    "name": item['faculty_name'].toString(),
                    "dept": item['department'].toString(),
                    "in": item['punch_in'].toString(),
                    "out": item['punch_out'].toString(),
                    "hrs": item['working_hours'].toString(),
                    "ontime": item['on_time'].toString(),
                    "remark": item['remark'].toString(),
                  })
              .toList();
        } else {
          reportData = [];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'No data found.')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load working hours report: $e')),
      );
      setState(() {
        reportData = [];
      });
    }
  }

  void _downloadReportAsCsv() async {
    if (reportData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to download.')),
      );
      return;
    }

    // Request storage permission
    if (await Permission.storage.request().isGranted) {
      try {
        // Create CSV content
        List<String> csvRows = [];
        // Add header
        csvRows.add(reportData[0].keys.join(','));
        // Add data rows
        for (var row in reportData) {
          csvRows.add(
              row.values.map((e) => '"${e.replaceAll('"', '""')}"').join(','));
        }

        final String csvContent = csvRows.join('\n');

        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/report_${DateTime.now().millisecondsSinceEpoch}.csv';
        final file = File(path);
        await file.writeAsString(csvContent);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report downloaded to $path')),
        );

        // Open the file
        OpenFilex.open(path);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download report: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HR"),
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
        actions: [
          TextButton(
            onPressed: _toggleReportView,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Text color
            ),
            child: Text(
              _showMonthlyReport
                  ? "Switch To Daily Reports"
                  : "Switch To Monthly Report",
            ),
          ),
          IconButton(
            onPressed: _downloadReportAsCsv,
            icon: const Icon(Icons.download),
            tooltip: 'Download CSV',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Report Generation",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_showMonthlyReport)
              // Monthly Report UI
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("From Date"),
                            TextField(
                              readOnly: true,
                              onTap: () =>
                                  _pickDate(context, onDateSelected: (date) {
                                setState(() {
                                  monthlyFromDate = date;
                                });
                              }),
                              controller: TextEditingController(
                                text: monthlyFromDate == null
                                    ? ""
                                    : "${monthlyFromDate!.day}-${monthlyFromDate!.month}-${monthlyFromDate!.year}",
                              ),
                              decoration: const InputDecoration(
                                hintText: 'dd-mm-yyyy',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("To Date"),
                            TextField(
                              readOnly: true,
                              onTap: () =>
                                  _pickDate(context, onDateSelected: (date) {
                                setState(() {
                                  monthlyToDate = date;
                                });
                              }),
                              controller: TextEditingController(
                                text: monthlyToDate == null
                                    ? ""
                                    : "${monthlyToDate!.day}-${monthlyToDate!.month}-${monthlyToDate!.year}",
                              ),
                              decoration: const InputDecoration(
                                hintText: 'dd-mm-yyyy',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _generateMonthlyReport,
                          child: const Text("Monthly Report"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _generateWorkingHoursReport,
                          child: const Text("Working Hours Report"),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              // Daily Report UI
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Date"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          onTap: () =>
                              _pickDate(context, onDateSelected: (date) {
                            setState(() {
                              dailySelectedDate = date;
                            });
                          }),
                          controller: TextEditingController(
                            text: dailySelectedDate == null
                                ? ""
                                : "${dailySelectedDate!.day}-${dailySelectedDate!.month}-${dailySelectedDate!.year}",
                          ),
                          decoration: const InputDecoration(
                            hintText: 'dd-mm-yyyy',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _generateDailyReport,
                        child: const Text("Generate"),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Map<String, dynamic>>.empty();
                }
                return _allFaculties.where((faculty) {
                  final name = faculty['name']?.toString().toLowerCase() ?? '';
                  return name.contains(textEditingValue.text.toLowerCase());
                });
              },
              displayStringForOption: (option) =>
                  option['name']?.toString() ?? '',
              onSelected: (Map<String, dynamic> selection) {
                _selectedFacultyNameForSearch = selection['name']?.toString();
                // You might want to trigger a report data filter here based on _selectedFacultyNameForSearch
              },
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController fieldTextEditingController,
                FocusNode fieldFocusNode,
                VoidCallback onFieldSubmitted,
              ) {
                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(
                    hintText: "Search Faculty...",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (query) {
                    searchController.text =
                        query; // Keep the original searchController updated
                    _filterReportDataByFaculty(query);
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              "Total Faculties: ${reportData.length}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            if (reportData.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Faculty ID")),
                    DataColumn(label: Text("Faculty Name")),
                    DataColumn(label: Text("Department")),
                    DataColumn(label: Text("Punch In")),
                    DataColumn(label: Text("Punch Out")),
                    DataColumn(label: Text("Working Hours")),
                    DataColumn(label: Text("On Time")),
                    DataColumn(label: Text("Remark")),
                  ],
                  rows: reportData.map((data) {
                    return DataRow(
                      cells: [
                        DataCell(Text(data["date"]!)),
                        DataCell(Text(data["id"]!)),
                        DataCell(Text(data["name"]!)),
                        DataCell(Text(data["dept"]!)),
                        DataCell(Text(data["in"]!)),
                        DataCell(Text(data["out"]!)),
                        DataCell(Text(data["hrs"]!)),
                        DataCell(Text(data["ontime"]!)),
                        DataCell(Text(data["remark"]!)),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

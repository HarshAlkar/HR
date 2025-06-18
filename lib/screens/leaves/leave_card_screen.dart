import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:hr/screens/app_drawer.dart';
import 'package:hr/services/api_service.dart';
import 'package:permission_handler/permission_handler.dart';

class LeaveCardScreen extends StatefulWidget {
  const LeaveCardScreen({super.key});

  @override
  State<LeaveCardScreen> createState() => _LeaveCardScreenState();
}

class _LeaveCardScreenState extends State<LeaveCardScreen> {
  final TextEditingController _reportFromDateController =
      TextEditingController();
  final TextEditingController _reportToDateController = TextEditingController();
  final TextEditingController _generateFacultyNameController =
      TextEditingController();

  List<Map<String, dynamic>> _facultyList = [];
  List<Map<String, dynamic>> _filteredFacultyList = [];
  String? _selectedFacultyId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFacultyNames();
  }

  Future<void> _fetchFacultyNames() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.fetchAllFacultyIds();
      print('Faculty List API Response: $response');
      if (response['facultylist'] != null) {
        setState(() {
          _facultyList =
              List<Map<String, dynamic>>.from(response['facultylist']);
          _filteredFacultyList = _facultyList;
        });
      }
    } catch (e) {
      print('Error in _fetchFacultyNames: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching faculty names: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterFaculty(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFacultyList = _facultyList;
      } else {
        _filteredFacultyList = _facultyList.where((faculty) {
          final name = faculty['name']?.toString().toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _downloadReport() async {
    if (_reportFromDateController.text.isEmpty ||
        _reportToDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both From Date and To Date.'),
        ),
      );
      return;
    }

    // Format dates to YYYY-MM-DD
    final formattedFromDate = DateFormat('yyyy-MM-dd').format(
      DateFormat('dd-MM-yyyy').parse(_reportFromDateController.text),
    );
    final formattedToDate = DateFormat('yyyy-MM-dd').format(
      DateFormat('dd-MM-yyyy').parse(_reportToDateController.text),
    );

    try {
      setState(() => _isLoading = true);

      // Request storage permission
      if (await Permission.storage.request().isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading report...')),
        );

        final response = await ApiService.downloadFacultyLeaveReport(
          fromDate: formattedFromDate,
          toDate: formattedToDate,
        );

        if (response.statusCode == 200) {
          // Get the downloads directory
          final directory = await getApplicationDocumentsDirectory();
          final fileName =
              'leave_report_${formattedFromDate}_to_${formattedToDate}.csv';
          final filePath = '${directory.path}/$fileName';
          final File file = File(filePath);

          // Write the CSV data to the file
          await file.writeAsBytes(response.bodyBytes);

          // Try to open the file
          final result = await OpenFilex.open(filePath);

          if (result.type == ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Report downloaded successfully: $fileName'),
                action: SnackBarAction(
                  label: 'Open',
                  onPressed: () => OpenFilex.open(filePath),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'File saved but could not be opened: ${result.message}'),
                action: SnackBarAction(
                  label: 'Open',
                  onPressed: () => OpenFilex.open(filePath),
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to download report: ${response.statusCode}'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Storage permission is required to download the report.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading report: $e'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyLeave() async {
    if (_selectedFacultyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a faculty.')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      final response = await ApiService.applyLeave(
        facultyId: _selectedFacultyId!,
        fromDate: _reportFromDateController.text,
        toDate: _reportToDateController.text,
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Leave application submitted successfully.')),
        );
        // Clear the form
        _reportFromDateController.clear();
        _reportToDateController.clear();
        _generateFacultyNameController.clear();
        setState(() {
          _selectedFacultyId = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                response['message'] ?? 'Failed to submit leave application.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting leave application: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _reportFromDateController.dispose();
    _reportToDateController.dispose();
    _generateFacultyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Card'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Download Leave Card Report (All Faculties)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('From Date :'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _reportFromDateController,
                                readOnly: true,
                                onTap: () => _selectDate(
                                  context,
                                  _reportFromDateController,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'dd-mm-yyyy',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                  isDense: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('To Date :'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _reportToDateController,
                                readOnly: true,
                                onTap: () => _selectDate(
                                  context,
                                  _reportToDateController,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'dd-mm-yyyy',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                  isDense: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _downloadReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A1070),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          child: const Text('Download Report'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generate Leave Card',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Faculty Name:'),
                    const SizedBox(height: 8),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Autocomplete<Map<String, dynamic>>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<
                                    Map<String, dynamic>>.empty();
                              }
                              return _filteredFacultyList.where((faculty) {
                                final name =
                                    faculty['name']?.toString().toLowerCase() ??
                                        '';
                                return name.contains(
                                    textEditingValue.text.toLowerCase());
                              });
                            },
                            displayStringForOption: (option) =>
                                option['name']?.toString() ?? '',
                            onSelected: (Map<String, dynamic> selection) {
                              _generateFacultyNameController.text =
                                  selection['name']?.toString() ?? '';
                              _selectedFacultyId =
                                  selection['faculty_id']?.toString();
                            },
                            fieldViewBuilder: (
                              BuildContext context,
                              TextEditingController fieldController,
                              FocusNode fieldFocusNode,
                              VoidCallback onFieldSubmitted,
                            ) {
                              _generateFacultyNameController.text =
                                  fieldController
                                      .text; // Keep internal controller updated
                              return TextField(
                                controller: fieldController,
                                focusNode: fieldFocusNode,
                                decoration: InputDecoration(
                                  hintText: "Search Faculty Name",
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.arrow_drop_down),
                                    onPressed: () {
                                      fieldFocusNode
                                          .requestFocus(); // Request focus to open options
                                    },
                                  ),
                                  isDense: true,
                                ),
                                onChanged: _filterFaculty,
                              );
                            },
                          ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _applyLeave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A1070),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

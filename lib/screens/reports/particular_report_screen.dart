import 'package:flutter/material.dart';
import '../app_drawer.dart';
import '../../services/api_service.dart';

class ParticularReportScreen extends StatefulWidget {
  const ParticularReportScreen({super.key});

  @override
  State<ParticularReportScreen> createState() => _ParticularReportScreenState();
}

class _ParticularReportScreenState extends State<ParticularReportScreen> {
  final TextEditingController nameController = TextEditingController();
  DateTime? fromDate, toDate;
  List<Map<String, String>> reportData = [];
  bool isAttendance = true;
  bool isLoading = false;
  List<Map<String, dynamic>> facultyList = [];
  List<Map<String, dynamic>> filteredFacultyList = [];
  String? _selectedFacultyId;

  @override
  void initState() {
    super.initState();
    _loadFacultyData();
  }

  Future<void> _loadFacultyData() async {
    try {
      setState(() => isLoading = true);
      final response = await ApiService.getAllFacultyNames();
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          facultyList = List<Map<String, dynamic>>.from(response['data'] ?? []);
          filteredFacultyList = facultyList;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(response['message'] ?? 'Failed to load faculty names')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading faculty names: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterFaculty(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFacultyList = facultyList;
      } else {
        filteredFacultyList = facultyList.where((faculty) {
          final name = faculty['name']?.toString().toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  bool isValidForm() {
    return _selectedFacultyId != null && fromDate != null && toDate != null;
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        isFrom ? fromDate = picked : toDate = picked;
      });
    }
  }

  Future<void> _fetchAttendance() async {
    if (!isValidForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select faculty and dates.")),
      );
      return;
    }

    final formattedFromDate =
        "${fromDate!.year}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}";
    final formattedToDate =
        "${toDate!.year}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}";

    try {
      setState(() => isLoading = true);
      final response = await ApiService.getParticularFacultyAttendanceReport(
        facultyId: _selectedFacultyId!,
        fromDate: formattedFromDate,
        toDate: formattedToDate,
      );
      setState(() {
        isAttendance = true;
        if (response['status'] == true && response['data'] != null) {
          reportData = (response['data'] as List)
              .map((item) => {
                    "name": item['faculty_name']?.toString() ?? '',
                    "date": item['date']?.toString() ?? '',
                    "remark": item['remark']?.toString() ?? '',
                    "in": item['punch_in']?.toString() ?? '',
                    "out": item['punch_out']?.toString() ?? '',
                    "hrs": item['working_hours']?.toString() ?? '',
                    "ontime": item['on_time']?.toString() ?? '',
                  })
              .toList();
        } else {
          reportData = [];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(response['message'] ?? 'No attendance data found.')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching attendance: $e')),
      );
      setState(() {
        reportData = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchReport() async {
    if (!isValidForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select faculty and dates.")),
      );
      return;
    }

    final formattedFromDate =
        "${fromDate!.year}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}";
    final formattedToDate =
        "${toDate!.year}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}";

    try {
      setState(() => isLoading = true);
      final response = await ApiService.getParticularFacultyLeaveReport(
        facultyId: _selectedFacultyId!,
        fromDate: formattedFromDate,
        toDate: formattedToDate,
      );
      setState(() {
        isAttendance = false;
        if (response['status'] == true && response['data'] != null) {
          reportData = (response['data'] as List)
              .map((item) => {
                    "leaveId": item['leave_id']?.toString() ?? '',
                    "facultyId": item['faculty_id']?.toString() ?? '',
                    "department": item['department']?.toString() ?? '',
                    "leaveType": item['leave_type']?.toString() ?? '',
                    "from": item['from_date']?.toString() ?? '',
                    "to": item['to_date']?.toString() ?? '',
                    "reason": item['reason']?.toString() ?? '',
                    "days": item['number_of_days']?.toString() ?? '',
                    "docLink": item['document_link']?.toString() ?? '',
                    "halfFull": item['half_full_day']?.toString() ?? '',
                    "hod": item['hod_status']?.toString() ?? '',
                    "principal": item['principal_status']?.toString() ?? '',
                    "alternate": item['alternate_faculty']?.toString() ?? '',
                    "status": item['status']?.toString() ?? '',
                  })
              .toList();
        } else {
          reportData = [];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ?? 'No leave data found.')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching leave report: $e')),
      );
      setState(() {
        reportData = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Particular Faculty Report"),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Generate Faculty Report",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text("Faculty Name"),
                  Autocomplete<Map<String, dynamic>>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Map<String, dynamic>>.empty();
                      }
                      return filteredFacultyList.where((faculty) {
                        final name =
                            faculty['name']?.toString().toLowerCase() ?? '';
                        return name
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    displayStringForOption: (option) =>
                        option['name']?.toString() ?? '',
                    onSelected: (Map<String, dynamic> selection) {
                      nameController.text = selection['name']?.toString() ?? '';
                      _selectedFacultyId = selection['id']?.toString();
                    },
                    fieldViewBuilder: (
                      BuildContext context,
                      TextEditingController fieldController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
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
                              fieldFocusNode.requestFocus();
                            },
                          ),
                        ),
                        onChanged: _filterFaculty,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          onTap: () => _pickDate(true),
                          decoration: InputDecoration(
                            hintText: fromDate == null
                                ? 'From Date'
                                : "${fromDate!.day}-${fromDate!.month}-${fromDate!.year}",
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          onTap: () => _pickDate(false),
                          decoration: InputDecoration(
                            hintText: toDate == null
                                ? 'To Date'
                                : "${toDate!.day}-${toDate!.month}-${toDate!.year}",
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _fetchAttendance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 195, 210, 221),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Fetch Attendance",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _fetchReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 195, 210, 221),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Fetch Report",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (reportData.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: isAttendance
                            ? const [
                                DataColumn(label: Text("Name")),
                                DataColumn(label: Text("Date")),
                                DataColumn(label: Text("Remark")),
                                DataColumn(label: Text("In")),
                                DataColumn(label: Text("Out")),
                                DataColumn(label: Text("Hours")),
                                DataColumn(label: Text("On Time")),
                              ]
                            : const [
                                DataColumn(label: Text("Leave ID")),
                                DataColumn(label: Text("Faculty ID")),
                                DataColumn(label: Text("Department")),
                                DataColumn(label: Text("Leave Type")),
                                DataColumn(label: Text("From")),
                                DataColumn(label: Text("To")),
                                DataColumn(label: Text("Reason")),
                                DataColumn(label: Text("Days")),
                                DataColumn(label: Text("Document")),
                                DataColumn(label: Text("Half/Full")),
                                DataColumn(label: Text("HOD")),
                                DataColumn(label: Text("Principal")),
                                DataColumn(label: Text("Alternate")),
                                DataColumn(label: Text("Status")),
                              ],
                        rows: reportData.map((data) {
                          return DataRow(
                            cells: isAttendance
                                ? [
                                    DataCell(Text(data["name"] ?? "")),
                                    DataCell(Text(data["date"] ?? "")),
                                    DataCell(Text(data["remark"] ?? "")),
                                    DataCell(Text(data["in"] ?? "")),
                                    DataCell(Text(data["out"] ?? "")),
                                    DataCell(Text(data["hrs"] ?? "")),
                                    DataCell(Text(data["ontime"] ?? "")),
                                  ]
                                : [
                                    DataCell(Text(data["leaveId"] ?? "")),
                                    DataCell(Text(data["facultyId"] ?? "")),
                                    DataCell(Text(data["department"] ?? "")),
                                    DataCell(Text(data["leaveType"] ?? "")),
                                    DataCell(Text(data["from"] ?? "")),
                                    DataCell(Text(data["to"] ?? "")),
                                    DataCell(Text(data["reason"] ?? "")),
                                    DataCell(Text(data["days"] ?? "")),
                                    DataCell(Text(data["docLink"] ?? "")),
                                    DataCell(Text(data["halfFull"] ?? "")),
                                    DataCell(Text(data["hod"] ?? "")),
                                    DataCell(Text(data["principal"] ?? "")),
                                    DataCell(Text(data["alternate"] ?? "")),
                                    DataCell(Text(data["status"] ?? "")),
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

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}

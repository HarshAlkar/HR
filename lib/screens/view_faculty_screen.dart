import 'package:flutter/material.dart';
import 'package:hr/screens/app_drawer.dart';
import 'package:hr/services/api_service.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hr/screens/faculty/edit_faculty_screen.dart';

class Faculty {
  final String facultyId;
  final String name;
  final String department;
  final String designation;
  final String email;
  final String contact;
  final String joiningDate;
  final String? alternateMobile;
  final String? gender;
  final String? dateOfBirth;
  final String? qualification;
  final String? panNumber;
  final String? aadharCard;
  final String? bloodGroup;
  final String? permanentAddress;
  final String? currentAddress;
  final String? experienceDetails;
  final String? photoPath;
  final String? signaturePath;
  final String? cvPath;

  Faculty({
    required this.facultyId,
    required this.name,
    required this.department,
    required this.designation,
    required this.email,
    required this.contact,
    required this.joiningDate,
    this.alternateMobile,
    this.gender,
    this.dateOfBirth,
    this.qualification,
    this.panNumber,
    this.aadharCard,
    this.bloodGroup,
    this.permanentAddress,
    this.currentAddress,
    this.experienceDetails,
    this.photoPath,
    this.signaturePath,
    this.cvPath,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      facultyId: json['faculty_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      contact: json['contact']?.toString() ?? '',
      joiningDate: json['joining_date']?.toString() ?? '',
      alternateMobile: json['alternate_mobile']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      qualification: json['qualification']?.toString(),
      panNumber: json['pan_number']?.toString(),
      aadharCard: json['aadhar_card']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      permanentAddress: json['permanent_address']?.toString(),
      currentAddress: json['current_address']?.toString(),
      experienceDetails: json['experience_details']?.toString(),
      photoPath: json['photo_path']?.toString(),
      signaturePath: json['signature_path']?.toString(),
      cvPath: json['cv_path']?.toString(),
    );
  }
}

class ViewFacultyScreen extends StatefulWidget {
  const ViewFacultyScreen({super.key});

  @override
  State<ViewFacultyScreen> createState() => _ViewFacultyScreenState();
}

class _ViewFacultyScreenState extends State<ViewFacultyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedDepartment;
  bool _isLoading = false;
  List<Faculty> facultyList = [];
  List<Faculty> filteredFacultyList = [];
  List<String> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadFacultyData();
  }

  Future<void> _loadFacultyData() async {
    setState(() => _isLoading = true);
    try {
      final facultyData = await ApiService.getAllFaculty();
      setState(() {
        facultyList =
            facultyData.map((data) => Faculty.fromJson(data)).toList();
        _updateFilteredList();
        _departments = facultyList.map((f) => f.department).toSet().toList()
          ..sort();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading faculty data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateFilteredList() {
    var filtered = facultyList;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchLower = _searchController.text.toLowerCase();
      filtered = filtered.where((faculty) {
        return faculty.name.toLowerCase().contains(searchLower) ||
            faculty.email.toLowerCase().contains(searchLower) ||
            faculty.contact.contains(searchLower) ||
            faculty.department.toLowerCase().contains(searchLower);
      }).toList();
    }

    // Apply department filter
    if (_selectedDepartment != null) {
      filtered = filtered
          .where((faculty) => faculty.department == _selectedDepartment)
          .toList();
    }

    setState(() {
      filteredFacultyList = filtered;
    });
  }

  Future<void> _deleteFaculty(String facultyId) async {
    try {
      setState(() => _isLoading = true);
      final response = await ApiService.deleteFaculty(facultyId);
      if (response['message'] == 'Faculty Deleted Successfully') {
        await _loadFacultyData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faculty deleted successfully')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Failed to delete faculty')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting faculty: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildFacultyCard(Faculty faculty) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faculty.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A1070),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${faculty.facultyId}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditFacultyScreen(faculty: faculty),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text(
                                'Are you sure you want to delete this faculty?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteFaculty(faculty.facultyId);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow([
              _buildInfoItem('Department', faculty.department),
              _buildInfoItem('Designation', faculty.designation),
            ]),
            const SizedBox(height: 8),
            _buildInfoRow([
              _buildInfoItem('Email', faculty.email),
              _buildInfoItem('Contact', faculty.contact),
            ]),
            const SizedBox(height: 8),
            _buildInfoItem('Joining Date', faculty.joiningDate),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(List<Widget> children) {
    return Row(
      children: children.map((child) => Expanded(child: child)).toList(),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty List'),
        backgroundColor: const Color(0xFF2A1070),
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () async {
              setState(() => _isLoading = true);
              bool success = await ApiService.downloadAllFaculty();
              setState(() => _isLoading = false);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Faculty report downloaded!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to download report.')),
                  );
                }
              }
            },
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text(
              'Download Report',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Faculty List',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A1070),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search faculty...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          onChanged: (value) => _updateFilteredList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Departments'),
                      ),
                      ..._departments.map(
                        (dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value;
                        _updateFilteredList();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Faculties: ${filteredFacultyList.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredFacultyList.isEmpty
                        ? const Center(
                            child: Text(
                              'No faculty data found. Please check back later or add new faculty.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredFacultyList.length,
                            itemBuilder: (context, index) {
                              return _buildFacultyCard(
                                  filteredFacultyList[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

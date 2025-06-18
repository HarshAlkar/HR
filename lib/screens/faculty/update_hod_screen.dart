import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/department.dart';
import '../../models/faculty.dart';
import '../view_faculty_screen.dart' hide Faculty;
import '../app_drawer.dart';

class UpdateHodScreen extends StatefulWidget {
  const UpdateHodScreen({super.key});

  @override
  State<UpdateHodScreen> createState() => _UpdateHodScreenState();
}

class _UpdateHodScreenState extends State<UpdateHodScreen> {
  String? _selectedDepartmentId;
  String? _selectedFacultyId;
  String _currentHodName = 'No HOD Allotted';
  List<Department> _departments = [];
  List<Department> _filteredDepartments = [];
  List<Faculty> _faculties = [];
  List<Faculty> _filteredFaculties = [];
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _facultySearchController =
      TextEditingController();
  final TextEditingController _departmentSearchController =
      TextEditingController();
  final FocusNode _departmentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _facultySearchController.addListener(_onFacultySearchChanged);
    _departmentSearchController.addListener(_onDepartmentSearchChanged);
    _departmentFocusNode.addListener(() {
      if (!_departmentFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _filteredDepartments = [];
            });
          }
        });
      } else {
        if (_departmentSearchController.text.isEmpty) {
          setState(() {
            _filteredDepartments = _departments;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _facultySearchController.removeListener(_onFacultySearchChanged);
    _facultySearchController.dispose();
    _departmentSearchController.removeListener(_onDepartmentSearchChanged);
    _departmentSearchController.dispose();
    _departmentFocusNode.dispose();
    super.dispose();
  }

  void _onDepartmentSearchChanged() {
    _filterDepartments(_departmentSearchController.text);
  }

  void _onFacultySearchChanged() {
    _filterFaculties(_facultySearchController.text);
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _fetchDepartments();
      await _fetchFaculties();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load initial data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDepartments() async {
    try {
      final response = await ApiService.getAllDepartments();
      print('Department API Response: $response');
      setState(() {
        _departments = (response['depart_list'] as List)
            .map((e) => Department.fromJson(e))
            .toList();
        _filteredDepartments = _departments;
        print('Fetched Departments: ${_departments.length}');
      });
    } catch (e) {
      print('Error fetching departments: $e');
      // Handle error
    }
  }

  Future<void> _fetchFaculties() async {
    try {
      final response = await ApiService.getAllFaculty();
      setState(() {
        _faculties =
            (response as List).map((e) => Faculty.fromJson(e)).toList();
        _filteredFaculties = _faculties;
      });
    } catch (e) {
      print('Error fetching faculties: $e');
      // Handle error
    }
  }

  void _filterDepartments(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDepartments = _departments;
      } else {
        _filteredDepartments = _departments.where((department) {
          final departmentNameLower = department.name.toLowerCase();
          final queryLower = query.toLowerCase();
          return departmentNameLower.contains(queryLower);
        }).toList();
      }
      print(
          'Filtered Departments count: ${_filteredDepartments.length}, Query: $query');
    });
  }

  void _filterFaculties(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFaculties = _faculties;
      } else {
        _filteredFaculties = _faculties.where((faculty) {
          final facultyNameLower = faculty.name.toLowerCase();
          final queryLower = query.toLowerCase();
          return facultyNameLower.contains(queryLower);
        }).toList();
      }
    });
  }

  Future<void> _fetchCurrentHod(String departmentId) async {
    setState(() {
      _isLoading = true;
      _currentHodName = 'Loading...';
    });
    try {
      final response = await ApiService.getHodByDepartment(departmentId);
      if (response != null && response['name'] != null) {
        setState(() {
          _currentHodName = response['name'];
        });
      } else {
        setState(() {
          _currentHodName = 'No HOD Allotted';
        });
      }
    } catch (e) {
      print('Error fetching current HOD: $e');
      setState(() {
        _currentHodName = 'Error loading HOD';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateHod() async {
    if (_selectedDepartmentId == null || _selectedFacultyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both a department and a new HOD.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.updateHod(
        departmentId: _selectedDepartmentId!,
        facultyId: _selectedFacultyId!,
      );

      if (response['status'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('HOD updated successfully!')),
        );
        _fetchCurrentHod(_selectedDepartmentId!); // Refresh current HOD
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Failed to update HOD')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating HOD: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update HOD'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a Department',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _departmentSearchController,
                              focusNode: _departmentFocusNode,
                              decoration: const InputDecoration(
                                hintText: 'Search Department',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (value) {
                                _filterDepartments(value);
                              },
                            ),
                            if (_departmentFocusNode.hasFocus ||
                                _departmentSearchController.text.isNotEmpty)
                              if (_filteredDepartments.isNotEmpty)
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    itemCount: _filteredDepartments.length,
                                    itemBuilder: (context, index) {
                                      final department =
                                          _filteredDepartments[index];
                                      return ListTile(
                                        title: Text(department.name),
                                        onTap: () {
                                          setState(() {
                                            _selectedDepartmentId =
                                                department.id;
                                            _departmentSearchController.text =
                                                department.name;
                                            _filteredDepartments = [];
                                            _departmentFocusNode.unfocus();
                                            _fetchCurrentHod(department.id!);
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Current HOD : $_currentHodName',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select new HOD',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _facultySearchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Faculty',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _filterFaculties(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredFaculties.length,
                      itemBuilder: (context, index) {
                        final faculty = _filteredFaculties[index];
                        return ListTile(
                          title: Text(faculty.name),
                          onTap: () {
                            setState(() {
                              _selectedFacultyId = faculty.facultyClgId;
                              _facultySearchController.text = faculty.name;
                              _filteredFaculties =
                                  []; // Clear filtered list after selection
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateHod,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A1070),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Update HOD'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

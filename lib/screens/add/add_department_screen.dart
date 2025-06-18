import 'package:flutter/material.dart';
import '../app_drawer.dart';
import '../../services/api_service.dart';

class AddDepartmentScreen extends StatefulWidget {
  const AddDepartmentScreen({super.key});

  @override
  State<AddDepartmentScreen> createState() => _AddDepartmentScreenState();
}

class _AddDepartmentScreenState extends State<AddDepartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _departmentNameController =
      TextEditingController();
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAndSetDepartments();
  }

  Future<void> _fetchAndSetDepartments() async {
    if (!mounted)
      return; // Always check mounted at the beginning of async methods
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getDepartments();
      print('Load Departments API Response: $response');

      final List<dynamic> departmentData = response['depart_list'] ?? [];
      print('Raw departmentData list size: ${departmentData.length}');

      final List<Map<String, dynamic>> processedDepartments = departmentData
          .map((data) {
            return {
              'id': data['depart_id']?.toString() ?? '',
              'name': data['name']?.toString() ?? '',
            };
          })
          .where((dept) =>
              dept['name'] != null &&
              dept['name'] != 'string' &&
              dept['name']!.isNotEmpty)
          .toList();

      print(
          'Processed (filtered) departments list size: ${processedDepartments.length}');
      processedDepartments
          .forEach((dept) => print('Processed Department: ${dept['name']}'));

      if (!mounted) return;
      print(
          'Before setState in _fetchAndSetDepartments. processedDepartments size: ${processedDepartments.length}');
      setState(() {
        _departments = processedDepartments;
        _isLoading = false;
        print(
            'Departments list updated in setState. New size: ${_departments.length}');
      });
      print('After setState in _fetchAndSetDepartments.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading departments: $e')),
      );
    }
  }

  Future<void> _addDepartment() async {
    if (!mounted)
      return; // Always check mounted at the beginning of async methods
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final response = await ApiService.addDepartment(
          name: _departmentNameController.text,
          code: "",
          hodId: "",
          description: "",
        );
        print('Add Department API Response: $response');

        if (!mounted) return;
        if (response['message'] == 'Success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Department ${_departmentNameController.text} added successfully!',
              ),
            ),
          );
          _departmentNameController.clear();
          await _fetchAndSetDepartments();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['msg'] ?? 'Failed to add department'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding department: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _departmentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Building AddDepartmentScreen. Departments list size: ${_departments.length}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Department'),
        backgroundColor: Theme.of(context).primaryColor,
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
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 48.0),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Text(
                            'Add Department',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: _departmentNameController,
                          label: 'Department Name',
                          hintText: 'Enter department name',
                          validator: (value) => value!.isEmpty
                              ? 'Please enter department name'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Total Departments (from state): ${_departments.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _addDepartment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              'Add Department',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Visibility(
                          visible: _departments
                              .isNotEmpty, // Only show table if data exists
                          child: Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.hovered)) {
                                      return Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.08);
                                    }
                                    return Theme.of(context).primaryColor;
                                  },
                                ),
                                headingTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                border: TableBorder.all(color: Colors.black),
                                columns: const [
                                  DataColumn(label: Text('Sr. no')),
                                  DataColumn(label: Text('Department Name')),
                                ],
                                rows: _departments.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final department = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${index + 1}')),
                                      DataCell(Text(department['name'])),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _departments.isEmpty &&
                              !_isLoading, // Show message if empty and not loading
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'No departments available or failed to load.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: const Color(0xFFF2F5FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 16.0,
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}

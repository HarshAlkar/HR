import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hr/screens/app_drawer.dart';
import '../../services/api_service.dart';
import 'package:file_picker/file_picker.dart';

class AddFacultyScreen extends StatefulWidget {
  const AddFacultyScreen({super.key});

  @override
  State<AddFacultyScreen> createState() => _AddFacultyScreenState();
}

class _AddFacultyScreenState extends State<AddFacultyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _collegeIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateOfJoiningController =
      TextEditingController();

  Map<String, dynamic>? _selectedFacultyType;
  Map<String, dynamic>? _selectedDepartment;
  Map<String, dynamic>? _selectedDesignation;
  Map<String, dynamic>? _selectedFacultyShift;
  String? _fileName;

  List<Map<String, dynamic>> _facultyTypes = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _designations = [];
  List<Map<String, dynamic>> _shifts = [];
  bool _isDropdownLoading = false;
  String? _dropdownError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    setState(() {
      _isDropdownLoading = true;
      _dropdownError = null;
    });
    try {
      final rawData = await ApiService.getDepartments();
      print('Raw dropdown API data: ' + rawData.toString());
      if (rawData is Map) {
        final dynamic ftypeList = rawData['ftype_list'];
        final dynamic departList = rawData['depart_list'];
        final dynamic roleList = rawData['role'];
        setState(() {
          _facultyTypes = ftypeList is List
              ? List<Map<String, dynamic>>.from(ftypeList)
              : [];
          _departments = departList is List
              ? List<Map<String, dynamic>>.from(departList)
              : [];
          _designations =
              roleList is List ? List<Map<String, dynamic>>.from(roleList) : [];
        });

        // Fetch shifts separately
        final shiftsData = await ApiService.getShifts();
        print('Raw shifts API data: ' + shiftsData.toString());

        setState(() {
          _shifts = List<Map<String, dynamic>>.from(shiftsData);
        });
        print(_shifts[0]);

        print('Processed shifts data: ' + _shifts.toString());
      } else {
        setState(() {
          _dropdownError = 'Unexpected response format for dropdown data.';
        });
      }
    } catch (e) {
      setState(() {
        _dropdownError = 'Failed to load dropdown data: $e';
      });
    } finally {
      setState(() {
        _isDropdownLoading = false;
      });
    }
  }

  Map<String, dynamic> _toStringKeyedMap(Map raw) {
    final Map<String, dynamic> result = {};
    raw.forEach((key, value) {
      result[key.toString()] = value;
    });
    return result;
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateOfJoiningController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _addFaculty() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      print('Attempting to add faculty...');
      try {
        final response = await ApiService.addFaculty(
          facultyClgId: _collegeIdController.text.trim(),
          name: _nameController.text.trim(),
          contact: _phoneController.text.trim(),
          ftypeId: _selectedFacultyType?['ftype_id'] as int? ??
              0, // Default to 0 or handle null appropriately
          role: _selectedDesignation?['role_id'] as int? ??
              0, // Default to 0 or handle null appropriately
          departId: _selectedDepartment?['depart_id'] as int? ??
              0, // Default to 0 or handle null appropriately
          joiningDate: _dateOfJoiningController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          shiftId: _selectedFacultyShift?['shift_id'] as int? ??
              0, // Default to 0 or handle null appropriately
        );
        print('Add Faculty API Response: $response');

        if (response['status'] == 'success' ||
            response['message'] == 'Success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Faculty added successfully!')),
          );
          _formKey.currentState?.reset();
        } else {
          String errorMessage = response['message'] ?? 'Failed to add faculty';
          // Check for specific 'already exists' message from the API
          if (errorMessage.toLowerCase().contains('already exist') ||
              errorMessage.toLowerCase().contains('duplicate')) {
            errorMessage = 'User with this email already exist';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e, stackTrace) {
        print('Error adding faculty: $e');
        print('Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')), // Ensure error is visible
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _dateOfJoiningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Faculty'),
        backgroundColor: const Color(0xFF2A1070),
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu), // Hamburger icon
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: const AppDrawer(),
      body: _isDropdownLoading
          ? const Center(child: CircularProgressIndicator())
          : _dropdownError != null
              ? Center(
                  child: Text(_dropdownError!,
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
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
                                'Add Faculty',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2A1070),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _pickFile,
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Choose file'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _fileName ?? 'No file chosen',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _nameController,
                              label: 'Name',
                              hintText: 'Enter name',
                              validator: (value) =>
                                  value!.isEmpty ? 'Please enter name' : null,
                            ),
                            _buildTextField(
                              controller: _collegeIdController,
                              label: 'Faculty College ID',
                              hintText:
                                  'Enter Faculty College ID', // Example as per image
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter Faculty College ID'
                                  : null,
                            ),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              hintText: 'Enter email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value!.isEmpty) return 'Please enter email';
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Enter valid email';
                                }
                                return null;
                              },
                            ),
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hintText: 'Enter phone number',
                              keyboardType: TextInputType.phone,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter phone number'
                                  : null,
                            ),
                            _buildDropdownField(
                              label: 'Faculty Type',
                              value: _selectedFacultyType,
                              items: _facultyTypes,
                              onChanged: (Map<String, dynamic>? newValue) {
                                setState(() {
                                  _selectedFacultyType = newValue;
                                });
                              },
                              hintText: 'Select Faculty Type',
                              displayKey: 'ftname',
                            ),
                            _buildDropdownField(
                              label: 'Department',
                              value: _selectedDepartment,
                              items: _departments,
                              onChanged: (Map<String, dynamic>? newValue) {
                                setState(() {
                                  _selectedDepartment = newValue;
                                });
                              },
                              hintText: 'Select Department',
                              displayKey: 'name',
                            ),
                            _buildDropdownField(
                              label: 'Faculty Designation',
                              value: _selectedDesignation,
                              items: _designations,
                              onChanged: (Map<String, dynamic>? newValue) {
                                setState(() {
                                  _selectedDesignation = newValue;
                                });
                              },
                              hintText: 'Select Faculty Designation',
                              displayKey: 'name',
                            ),
                            _buildDropdownField(
                              label: 'Faculty Shift',
                              value: _selectedFacultyShift,
                              items: _shifts,
                              onChanged: (Map<String, dynamic>? newValue) {
                                setState(() {
                                  _selectedFacultyShift = newValue;
                                });
                              },
                              hintText: 'Select Faculty Shift',
                              displayKey: 'sname',
                            ),
                            _buildDateField(
                              controller: _dateOfJoiningController,
                              label: 'Date of Joining',
                              hintText: 'dd-mm-yyyy',
                              onTap: () => _selectDate(context),
                            ),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: '********',
                              obscureText: true,
                              validator: (value) {
                                if (value!.isEmpty)
                                  return 'Please enter password';
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _addFaculty,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B5996),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Add Faculty',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
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

  Widget _buildDropdownField({
    required String label,
    required Map<String, dynamic>? value,
    required List<Map<String, dynamic>> items,
    required void Function(Map<String, dynamic>?) onChanged,
    required String hintText,
    required String displayKey,
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
          DropdownButtonFormField<Map<String, dynamic>>(
            value: value,
            isExpanded: true,
            dropdownColor: Colors.white,
            style: const TextStyle(
                color: Colors.black,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold),
            decoration: InputDecoration(
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
            hint: Text(
              hintText,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w500),
            ),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<Map<String, dynamic>>>(
                (Map<String, dynamic> item) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: item,
                child: Text(
                  item[displayKey]?.toString() ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            validator: (val) =>
                val == null ? 'Please select a ${label.toLowerCase()}' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required VoidCallback onTap,
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
            readOnly: true,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: const Color(0xFFF2F5FF),
              suffixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 16.0,
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Please select date' : null,
          ),
        ],
      ),
    );
  }
}

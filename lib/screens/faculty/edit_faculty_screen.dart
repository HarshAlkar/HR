import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EditFacultyScreen extends StatefulWidget {
  final dynamic faculty;

  const EditFacultyScreen({super.key, required this.faculty});

  @override
  State<EditFacultyScreen> createState() => _EditFacultyScreenState();
}

class _EditFacultyScreenState extends State<EditFacultyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _alternateMobileController;
  late TextEditingController _departmentController;
  late TextEditingController _designationController;
  late TextEditingController _joiningDateController;
  late TextEditingController _genderController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _qualificationController;
  late TextEditingController _panNumberController;
  late TextEditingController _aadharCardController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _permanentAddressController;
  late TextEditingController _currentAddressController;
  late TextEditingController _experienceDetailsController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.faculty.name);
    _emailController = TextEditingController(text: widget.faculty.email);
    _contactController = TextEditingController(text: widget.faculty.contact);
    _alternateMobileController =
        TextEditingController(text: widget.faculty.alternateMobile);
    _departmentController =
        TextEditingController(text: widget.faculty.department);
    _designationController =
        TextEditingController(text: widget.faculty.designation);
    _joiningDateController =
        TextEditingController(text: widget.faculty.joiningDate);
    _genderController = TextEditingController(text: widget.faculty.gender);
    _dateOfBirthController =
        TextEditingController(text: widget.faculty.dateOfBirth);
    _qualificationController =
        TextEditingController(text: widget.faculty.qualification);
    _panNumberController =
        TextEditingController(text: widget.faculty.panNumber);
    _aadharCardController =
        TextEditingController(text: widget.faculty.aadharCard);
    _bloodGroupController =
        TextEditingController(text: widget.faculty.bloodGroup);
    _permanentAddressController =
        TextEditingController(text: widget.faculty.permanentAddress);
    _currentAddressController =
        TextEditingController(text: widget.faculty.currentAddress);
    _experienceDetailsController =
        TextEditingController(text: widget.faculty.experienceDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Faculty'),
        backgroundColor: const Color(0xFF2A1070),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Name', _nameController),
              _buildTextField('Email', _emailController),
              _buildTextField('Contact', _contactController),
              _buildTextField('Alternate Mobile', _alternateMobileController),
              _buildTextField('Department', _departmentController),
              _buildTextField('Designation', _designationController),
              _buildTextField('Joining Date', _joiningDateController),
              _buildTextField('Gender', _genderController),
              _buildTextField('Date of Birth', _dateOfBirthController),
              _buildTextField('Qualification', _qualificationController),
              _buildTextField('PAN Number', _panNumberController),
              _buildTextField('Aadhar Card', _aadharCardController),
              _buildTextField('Blood Group', _bloodGroupController),
              _buildTextField('Permanent Address', _permanentAddressController),
              _buildTextField('Current Address', _currentAddressController),
              _buildTextField(
                  'Experience Details', _experienceDetailsController),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _updateFaculty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A1070),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Update Faculty'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _updateFaculty() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedData = {
          'faculty_id': widget.faculty.facultyId,
          'name': _nameController.text,
          'email': _emailController.text,
          'contact': _contactController.text,
          'alternate_mobile': _alternateMobileController.text,
          'department': _departmentController.text,
          'designation': _designationController.text,
          'joining_date': _joiningDateController.text,
          'gender': _genderController.text,
          'date_of_birth': _dateOfBirthController.text,
          'qualification': _qualificationController.text,
          'pan_number': _panNumberController.text,
          'aadhar_card': _aadharCardController.text,
          'blood_group': _bloodGroupController.text,
          'permanent_address': _permanentAddressController.text,
          'current_address': _currentAddressController.text,
          'experience_details': _experienceDetailsController.text,
        };

        final response = await ApiService.updateFaculty(updatedData);
        if (response['status'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Faculty updated successfully')),
            );
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(response['message'] ?? 'Failed to update faculty')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating faculty: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _alternateMobileController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _joiningDateController.dispose();
    _genderController.dispose();
    _dateOfBirthController.dispose();
    _qualificationController.dispose();
    _panNumberController.dispose();
    _aadharCardController.dispose();
    _bloodGroupController.dispose();
    _permanentAddressController.dispose();
    _currentAddressController.dispose();
    _experienceDetailsController.dispose();
    super.dispose();
  }
}

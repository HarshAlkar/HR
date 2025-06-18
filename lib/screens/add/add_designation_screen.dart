import 'package:flutter/material.dart';
import '../app_drawer.dart';
import '../../services/api_service.dart'; // Import ApiService

class AddDesignationScreen extends StatefulWidget {
  const AddDesignationScreen({super.key});

  @override
  State<AddDesignationScreen> createState() => _AddDesignationScreenState();
}

class _AddDesignationScreenState extends State<AddDesignationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _designationNameController =
      TextEditingController();

  List<Map<String, dynamic>> _designations = []; // Change to dynamic list
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAndSetDesignations(); // Initial data fetch
  }

  Future<void> _fetchAndSetDesignations() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> response =
          await ApiService.getDesignations();
      print('Load Designations API Response: $response');

      final List<Map<String, dynamic>> processedDesignations = response
          .where((desig) =>
              desig['name'] != null &&
              desig['name'] != 'string' &&
              desig['name']!.isNotEmpty)
          .toList();

      print(
          'Processed (filtered) designations list size: ${processedDesignations.length}');
      processedDesignations
          .forEach((desig) => print('Processed Designation: ${desig['name']}'));

      if (!mounted) return;
      setState(() {
        _designations = processedDesignations;
        _isLoading = false;
        print(
            'Designations list updated in setState. New size: ${_designations.length}');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading designations: $e')),
      );
    }
  }

  Future<void> _addDesignation() async {
    if (!mounted) return;
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final response = await ApiService.addDesignation(
          name: _designationNameController.text,
        );
        print('Add Designation API Response: $response');

        if (!mounted) return;
        if (response['message'] == 'Success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Designation ${_designationNameController.text} added successfully!',
              ),
            ),
          );
          _designationNameController.clear();
          await _fetchAndSetDesignations(); // Reload designations after successful add
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['msg'] ?? 'Failed to add designation'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding designation: $e'),
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
    _designationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Building AddDesignationScreen. Designations list size: ${_designations.length}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Designation'),
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
                            'Add Designation',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: _designationNameController,
                          label: 'Designation Name',
                          hintText: 'Enter designation name',
                          validator: (value) => value!.isEmpty
                              ? 'Please enter designation name'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Total Designations (from state): ${_designations.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _addDesignation,
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
                              'Add Designation',
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
                          visible: _designations
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
                                  DataColumn(label: Text('Designation Name')),
                                ],
                                rows:
                                    _designations.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final designation = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${index + 1}')),
                                      DataCell(Text(designation['name'])),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _designations.isEmpty &&
                              !_isLoading, // Show message if empty and not loading
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'No designations available or failed to load.',
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

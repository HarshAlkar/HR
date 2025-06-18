import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../app_drawer.dart';

class FacultyLeaveBalanceScreen extends StatefulWidget {
  const FacultyLeaveBalanceScreen({super.key});

  @override
  State<FacultyLeaveBalanceScreen> createState() =>
      _FacultyLeaveBalanceScreenState();
}

class _FacultyLeaveBalanceScreenState extends State<FacultyLeaveBalanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allLeaveBalances = [];
  List<Map<String, dynamic>> _filteredLeaveBalances = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllLeaveBalances();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterLeaveBalances(_searchController.text);
  }

  Future<void> _loadAllLeaveBalances() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getFacultyLeaveBalance();
      print('API Response for getFacultyLeaveBalance: $response');
      if (response['balanceLeave'] != null &&
          response['balanceLeave'] is List) {
        setState(() {
          _allLeaveBalances =
              List<Map<String, dynamic>>.from(response['balanceLeave']);
          _filteredLeaveBalances =
              _allLeaveBalances; // Initialize filtered list with all data
        });
      } else {
        setState(() {
          _allLeaveBalances = [];
          _filteredLeaveBalances = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load leave balances: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterLeaveBalances(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLeaveBalances = _allLeaveBalances;
      } else {
        _filteredLeaveBalances = _allLeaveBalances.where((balance) {
          final facultyId =
              balance['faculty_id']?.toString().toLowerCase() ?? '';
          final facultyName =
              balance['faculty_name']?.toString().toLowerCase() ??
                  ''; // Assuming 'faculty_name' exists
          final lowerCaseQuery = query.toLowerCase();
          return facultyId.contains(lowerCaseQuery) ||
              facultyName.contains(lowerCaseQuery);
        }).toList();
      }
    });
  }

  Future<void> _updateLeaveBalance(Map<String, dynamic> leaveData) async {
    // Extract values from leaveData, assuming they are in the correct format or convert them.
    // Note: The UI fields are TextFields, so values will be Strings. Convert to int for API.
    final String facultyId = leaveData['faculty_id'].toString();
    final int cl = int.tryParse(leaveData['cl'].toString()) ?? 0;
    final int co = int.tryParse(leaveData['co'].toString()) ?? 0;
    final int ml = int.tryParse(leaveData['ml'].toString()) ?? 0;
    final int el = int.tryParse(leaveData['el'].toString()) ?? 0;
    final int sv = int.tryParse(leaveData['sv'].toString()) ?? 0;
    final int wv = int.tryParse(leaveData['wv'].toString()) ?? 0;
    final int sl = int.tryParse(leaveData['sl'].toString()) ?? 0;
    final int uel = int.tryParse(leaveData['uel'].toString()) ?? 0;
    final int mtl = int.tryParse(leaveData['mtl'].toString()) ?? 0;
    final String remark = leaveData['remark']?.toString() ?? '';

    try {
      final response = await ApiService.updateFacultyLeaveBalance(
        facultyId: facultyId,
        cl: cl,
        co: co,
        ml: ml,
        el: el,
        sv: sv,
        wv: wv,
        sl: sl,
        uel: uel,
        mtl: mtl,
        remark: remark,
      );
      // Handle success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                response['message'] ?? 'Leave balance updated successfully!')),
      );
      // Reload all balances after successful update to reflect changes
      _loadAllLeaveBalances();
    } catch (e) {
      // Handle error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update leave balance: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Leave Balance'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Faculty Name or ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : _errorMessage != null
                    ? Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      )
                    : _filteredLeaveBalances.isEmpty
                        ? const Center(
                            child: Text(
                              'No leave balance data found.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _filteredLeaveBalances.length,
                              itemBuilder: (context, index) {
                                final leaveData = _filteredLeaveBalances[index];
                                return _buildLeaveBalanceCard(leaveData);
                              },
                            ),
                          ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceCard(Map<String, dynamic> leaveData) {
    // Create TextEditingControllers for each editable field
    // and initialize them with the current leaveData values.
    final TextEditingController clController =
        TextEditingController(text: leaveData['Casual Leave']?.toString());
    final TextEditingController coController = TextEditingController(
        text: leaveData['Compensation Leave']?.toString());
    final TextEditingController mlController =
        TextEditingController(text: leaveData['Medical Leave']?.toString());
    final TextEditingController elController =
        TextEditingController(text: leaveData['Earned Leave']?.toString());
    final TextEditingController svController =
        TextEditingController(text: leaveData['Summer Vacation']?.toString());
    final TextEditingController wvController =
        TextEditingController(text: leaveData['Winter Vacation']?.toString());
    final TextEditingController slController =
        TextEditingController(text: leaveData['Special Leave']?.toString());
    final TextEditingController uelController = TextEditingController(
        text: leaveData['used_earned_leaves']?.toString());
    final TextEditingController mtlController =
        TextEditingController(text: leaveData['Maternity Leave']?.toString());
    final TextEditingController remarkController =
        TextEditingController(text: leaveData['remark']?.toString());

    // Create a local map to hold the current editable values
    final Map<String, dynamic> currentEditableLeaveData = Map.from(leaveData);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faculty: ${leaveData['name'] ?? 'N/A'} (ID: ${leaveData['faculty_id']})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            _buildEditableLeaveField('Casual Leave', clController,
                (value) => currentEditableLeaveData['Casual Leave'] = value),
            _buildEditableLeaveField(
                'Compensatory Off',
                coController,
                (value) =>
                    currentEditableLeaveData['Compensation Leave'] = value),
            _buildEditableLeaveField('Medical Leave', mlController,
                (value) => currentEditableLeaveData['Medical Leave'] = value),
            _buildEditableLeaveField('Earned Leave', elController,
                (value) => currentEditableLeaveData['Earned Leave'] = value),
            _buildEditableLeaveField('Study Visit', svController,
                (value) => currentEditableLeaveData['Summer Vacation'] = value),
            _buildEditableLeaveField('Work Visit', wvController,
                (value) => currentEditableLeaveData['Winter Vacation'] = value),
            _buildEditableLeaveField('Special Leave', slController,
                (value) => currentEditableLeaveData['Special Leave'] = value),
            _buildEditableLeaveField(
                'Unpaid Earned Leave',
                uelController,
                (value) =>
                    currentEditableLeaveData['used_earned_leaves'] = value),
            _buildEditableLeaveField('Maternity Leave', mtlController,
                (value) => currentEditableLeaveData['Maternity Leave'] = value),
            _buildEditableLeaveField('Remark', remarkController,
                (value) => currentEditableLeaveData['remark'] = value,
                keyboardType: TextInputType.text),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _updateLeaveBalance(currentEditableLeaveData),
                child: const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableLeaveField(String label,
      TextEditingController controller, Function(String) onChanged,
      {TextInputType keyboardType = TextInputType.number}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

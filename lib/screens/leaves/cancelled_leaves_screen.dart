import 'package:flutter/material.dart';
import '../app_drawer.dart'; // Import the AppDrawer
import 'package:hr/services/api_service.dart'; // Import ApiService

class CancelledLeavesScreen extends StatefulWidget {
  const CancelledLeavesScreen({super.key});

  @override
  State<CancelledLeavesScreen> createState() => _CancelledLeavesScreenState();
}

class CancelledLeave {
  final String facultyName;
  final double casualLeave;
  final double medicalLeave;
  final double earnedLeave;
  final double compensationLeave;
  final double summerVacation;
  final double winterVacation;
  final double specialLeave;
  final double usedEarnedLeaves;
  final String remark;

  CancelledLeave({
    required this.facultyName,
    required this.casualLeave,
    required this.medicalLeave,
    required this.earnedLeave,
    required this.compensationLeave,
    required this.summerVacation,
    required this.winterVacation,
    required this.specialLeave,
    required this.usedEarnedLeaves,
    required this.remark,
  });

  // Factory constructor to parse data from API response
  factory CancelledLeave.fromJson(Map<String, dynamic> json) {
    return CancelledLeave(
      facultyName: json['name']?.toString() ?? 'N/A',
      casualLeave:
          double.tryParse(json['Casual Leave']?.toString() ?? '') ?? 0.0,
      medicalLeave:
          double.tryParse(json['Medical Leave']?.toString() ?? '') ?? 0.0,
      earnedLeave:
          double.tryParse(json['Earned Leave']?.toString() ?? '') ?? 0.0,
      compensationLeave:
          double.tryParse(json['Compensation Leave']?.toString() ?? '') ?? 0.0,
      summerVacation:
          double.tryParse(json['Summer Vacation']?.toString() ?? '') ?? 0.0,
      winterVacation:
          double.tryParse(json['Winter Vacation']?.toString() ?? '') ?? 0.0,
      specialLeave:
          double.tryParse(json['Special Leave']?.toString() ?? '') ?? 0.0,
      usedEarnedLeaves:
          double.tryParse(json['used_earned_leaves']?.toString() ?? '') ?? 0.0,
      remark: json['remark']?.toString() ?? 'N/A',
    );
  }
}

class _CancelledLeavesScreenState extends State<CancelledLeavesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CancelledLeave> _cancelledLeaveList = []; // Change to empty list
  bool _isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();
    _fetchCancelledLeaves(); // Call API on init
  }

  Future<void> _fetchCancelledLeaves() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.getCancelledLeaves();
      print('Cancelled Leaves API Response: $response'); // Added for debugging
      if (response['message'] == 'Success' &&
          response['balanceLeave'] != null) {
        setState(() {
          _cancelledLeaveList = (response['balanceLeave'] as List)
              .map((item) => CancelledLeave.fromJson(item))
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(response['message'] ?? 'No cancelled leaves found.')),
        );
        setState(() {
          _cancelledLeaveList = []; // Clear list on no data
        });
      }
    } catch (e) {
      print('Error in _fetchCancelledLeaves: $e'); // Added for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching cancelled leaves: $e')),
      );
      setState(() {
        _cancelledLeaveList = []; // Clear list on error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<CancelledLeave> get _filteredCancelledLeaves {
    if (_searchController.text.isEmpty) {
      return _cancelledLeaveList;
    } else {
      return _cancelledLeaveList.where((leave) {
        return leave.facultyName.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
      }).toList();
    }
  }

  Widget _buildLeaveDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancelled Leaves'),
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
      drawer: const AppDrawer(), // Add the AppDrawer here
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Faculty name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator
                : Expanded(
                    child: ListView.builder(
                      itemCount: _filteredCancelledLeaves.length,
                      itemBuilder: (context, index) {
                        final leave = _filteredCancelledLeaves[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  leave.facultyName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Divider(height: 16),
                                _buildLeaveDetailRow(
                                  'Casual Leave:',
                                  leave.casualLeave,
                                ),
                                _buildLeaveDetailRow(
                                  'Medical Leave:',
                                  leave.medicalLeave,
                                ),
                                _buildLeaveDetailRow(
                                  'Earned Leave:',
                                  leave.earnedLeave,
                                ),
                                _buildLeaveDetailRow(
                                  'Compensation Leave:',
                                  leave.compensationLeave,
                                ),
                                _buildLeaveDetailRow(
                                  'Summer Vacation:',
                                  leave.summerVacation,
                                ),
                                _buildLeaveDetailRow(
                                  'Winter Vacation:',
                                  leave.winterVacation,
                                ),
                                _buildLeaveDetailRow(
                                  'Special Leave:',
                                  leave.specialLeave,
                                ),
                                _buildLeaveDetailRow(
                                  'Used Earned Leaves:',
                                  leave.usedEarnedLeaves,
                                ),
                                _buildLeaveDetailRow('Remark:', leave.remark),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../app_drawer.dart'; // Import the AppDrawer
import '../../services/api_service.dart';
import 'package:hr/screens/leaves/faculty_approved_list_screen.dart';
import 'dart:convert';

class FacultyLeaveApprovalScreen extends StatefulWidget {
  const FacultyLeaveApprovalScreen({super.key});

  @override
  State<FacultyLeaveApprovalScreen> createState() =>
      _FacultyLeaveApprovalScreenState();
}

class LeaveApplication {
  final String leaveAppId;
  final String facultyId;
  final String facultyName;
  final String post;
  final String leaveType;
  final String department;
  final double numberOfDays;
  final String leaveReason;
  final String fromDate;
  final String toDate;
  final String proof;
  final String chargeTaken;
  final String signedByHOD;
  final int leaveCategoryId;
  String approvalStatus;
  bool isSelected;

  LeaveApplication({
    required this.leaveAppId,
    required this.facultyId,
    required this.facultyName,
    required this.post,
    required this.leaveType,
    required this.department,
    required this.numberOfDays,
    required this.leaveReason,
    required this.fromDate,
    required this.toDate,
    required this.proof,
    required this.chargeTaken,
    required this.signedByHOD,
    required this.leaveCategoryId,
    this.approvalStatus = 'Pending',
    this.isSelected = false,
  });

  factory LeaveApplication.fromJson(Map<String, dynamic> json) {
    return LeaveApplication(
      leaveAppId: json['leave_app_id']?.toString() ?? '',
      facultyId:
          json['clgId']?.toString() ?? json['faculty_id']?.toString() ?? '',
      facultyName: json['name']?.toString() ?? '',
      post: json['role']?.toString() ?? '',
      leaveType: json['lname']?.toString() ?? '',
      department: json['dname']?.toString() ?? '',
      numberOfDays: (json['no_of_days'] as String?) != null
          ? double.tryParse(json['no_of_days']) ?? 0.0
          : 0.0,
      leaveReason: json['reason']?.toString() ?? '',
      fromDate: json['from_date']?.toString().split('T')[0] ?? '',
      toDate: json['to_date']?.toString().split('T')[0] ?? '',
      proof: json['doc_link']?.toString() ?? 'None',
      chargeTaken: json['altname']?.toString() ?? '',
      signedByHOD: json['hod_name']?.toString() ?? 'Pending',
      leaveCategoryId: json['leave_id'] as int? ?? 0,
      approvalStatus: _getApprovalStatus(json['status'], json['signed_by_hod']),
    );
  }

  static String _getApprovalStatus(dynamic status, dynamic signedByHod) {
    if (status == 1) {
      return 'Approved';
    } else if (status == 2) {
      return 'Denied';
    } else if (status == 0 && signedByHod == 0) {
      return 'Pending';
    } else {
      return 'Unknown';
    }
  }
}

class _FacultyLeaveApprovalScreenState
    extends State<FacultyLeaveApprovalScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LeaveApplication> leaveApplications = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _sortBy = 'date'; // 'date', 'name', 'type'
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaveApprovals();
  }

  Future<void> _fetchLeaveApprovals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getLeaveApprovals();
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['pendingList'] is List) {
          setState(() {
            leaveApplications = (responseData['pendingList'] as List)
                .map((item) => LeaveApplication.fromJson(item))
                .toList();
            print('Parsed Leave Applications: $leaveApplications');
          });
        } else {
          setState(() {
            _errorMessage =
                responseData['message'] ?? 'No leave applications found';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to load leave applications: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load leave applications: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<LeaveApplication> get filteredApplications {
    var filtered = leaveApplications;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((app) {
        return app.facultyName.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'date':
          comparison = a.fromDate.compareTo(b.fromDate);
          break;
        case 'name':
          comparison = a.facultyName.compareTo(b.facultyName);
          break;
        case 'type':
          comparison = a.leaveType.compareTo(b.leaveType);
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  Future<void> _approveApplication(LeaveApplication application) async {
    try {
      final response = await ApiService.updateLeaveStatus(
        leaveAppId: application.leaveAppId,
        status: 'Approved',
        noOfDays: application.numberOfDays.toString(),
        leaveId: application.leaveCategoryId.toString(),
        facultyId: application.facultyId,
      );
      print('Approve API Response: $response');

      if (response['status'] == true) {
        await _fetchLeaveApprovals();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Leave application approved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Failed to approve leave')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving leave: $e')),
      );
    }
  }

  Future<void> _denyApplication(LeaveApplication application) async {
    try {
      final response = await ApiService.updateLeaveStatus(
        leaveAppId: application.leaveAppId,
        status: 'Denied',
        noOfDays: application.numberOfDays.toString(),
        leaveId: application.leaveCategoryId.toString(),
        facultyId: application.facultyId,
      );
      print('Deny API Response: $response');

      if (response['status'] == true) {
        await _fetchLeaveApprovals();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Leave application denied successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Failed to deny leave')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error denying leave: $e')),
      );
    }
  }

  Future<void> _approveAllApplications() async {
    try {
      for (var app in leaveApplications) {
        if (app.approvalStatus == 'Pending') {
          await ApiService.updateLeaveStatus(
            leaveAppId: app.leaveAppId,
            status: 'Approved',
            noOfDays: app.numberOfDays.toString(),
            leaveId: app.leaveCategoryId.toString(),
            facultyId: app.facultyId,
          );
        }
      }
      await _fetchLeaveApprovals(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All pending applications approved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving all applications: $e')),
      );
    }
  }

  Future<void> _approveSelectedApplications() async {
    try {
      for (var app in leaveApplications) {
        if (app.isSelected && app.approvalStatus == 'Pending') {
          await ApiService.updateLeaveStatus(
            leaveAppId: app.leaveAppId,
            status: 'Approved',
            noOfDays: app.numberOfDays.toString(),
            leaveId: app.leaveCategoryId.toString(),
            facultyId: app.facultyId,
          );
        }
      }
      await _fetchLeaveApprovals(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected applications approved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving selected applications: $e')),
      );
    }
  }

  void _viewApprovedLeaves() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FacultyApprovedListScreen(),
      ),
    );
  }

  Future<void> _showConfirmationDialog(
      LeaveApplication application, bool isApprove) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Approve Leave?' : 'Deny Leave?'),
        content: Text(
          isApprove
              ? 'Are you sure you want to approve this leave application?'
              : 'Are you sure you want to deny this leave application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isApprove ? 'Approve' : 'Deny',
              style: TextStyle(
                color: isApprove ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      if (isApprove) {
        await _approveApplication(application);
      } else {
        await _denyApplication(application);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Leave Approval'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLeaveApprovals,
          ),
        ],
      ),
      drawer: const AppDrawer(), // Add the AppDrawer here
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Faculty name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Rebuild to filter results
                    },
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (String value) {
                    setState(() {
                      if (_sortBy == value) {
                        _sortAscending = !_sortAscending;
                      } else {
                        _sortBy = value;
                        _sortAscending = true;
                      }
                    });
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'date',
                      child: Text('Sort by Date'),
                    ),
                    const PopupMenuItem(
                      value: 'name',
                      child: Text('Sort by Name'),
                    ),
                    const PopupMenuItem(
                      value: 'type',
                      child: Text('Sort by Leave Type'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _approveAllApplications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A1070),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve All'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _approveSelectedApplications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A1070),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve Selected'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _viewApprovedLeaves,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A1070),
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Approved Leaves'),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredApplications.length,
                  itemBuilder: (context, index) {
                    final application = filteredApplications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: application.isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      application.isSelected = value!;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    application.facultyName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        application.approvalStatus == 'Pending'
                                            ? Colors.yellow.shade200
                                            : application.approvalStatus ==
                                                    'Approved'
                                                ? Colors.green.shade200
                                                : Colors.red.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    application.approvalStatus,
                                    style: TextStyle(
                                      color: application.approvalStatus ==
                                              'Pending'
                                          ? Colors.orange.shade900
                                          : application.approvalStatus ==
                                                  'Approved'
                                              ? Colors.green.shade900
                                              : Colors.red.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('College Id: ${application.facultyId}'),
                            Text('Post: ${application.post}'),
                            Text('Leave Type: ${application.leaveType}'),
                            Text('Department: ${application.department}'),
                            Text(
                              'Number of Days: ${application.numberOfDays.toStringAsFixed(2)}',
                            ),
                            Text('Leave Reason: ${application.leaveReason}'),
                            Text(
                              'From: ${application.fromDate} To: ${application.toDate}',
                            ),
                            Text('Proof: ${application.proof}'),
                            Text('Charge Taken: ${application.chargeTaken}'),
                            Text('Signed By HOD: ${application.signedByHOD}'),
                            if (application.approvalStatus == 'Pending')
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _showConfirmationDialog(
                                          application, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Approve'),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () => _showConfirmationDialog(
                                          application, false),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side:
                                            const BorderSide(color: Colors.red),
                                      ),
                                      child: const Text('Deny'),
                                    ),
                                  ],
                                ),
                              ),
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

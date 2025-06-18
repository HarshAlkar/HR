import 'package:flutter/material.dart';
import '../app_drawer.dart';
import '../../services/api_service.dart';
import 'dart:convert';

class ApproveProfileChangeScreen extends StatefulWidget {
  const ApproveProfileChangeScreen({super.key});

  @override
  State<ApproveProfileChangeScreen> createState() =>
      _ApproveProfileChangeScreenState();
}

class _ApproveProfileChangeScreenState
    extends State<ApproveProfileChangeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _pendingChanges = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingChanges();
  }

  Future<void> _fetchPendingChanges() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getUpdateFaculty();
      if (response['status'] == true) {
        setState(() {
          _pendingChanges =
              List<Map<String, dynamic>>.from(response['updates'] ?? []);
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Failed to fetch updates')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching updates: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveChange(String facultyId) async {
    try {
      final response = await ApiService.postApproveUpdate(facultyId: facultyId);
      if (response['status'] == true) {
        await _fetchPendingChanges();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update approved successfully')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Failed to approve update')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving update: $e')),
      );
    }
  }

  Future<void> _rejectChange(String facultyId) async {
    try {
      final response = await ApiService.postApproveUpdate(
        facultyId: facultyId,
        status: 'rejected',
      );
      if (response['status'] == true) {
        await _fetchPendingChanges();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update rejected successfully')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Failed to reject update')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting update: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredChanges {
    if (_searchController.text.isEmpty) {
      return _pendingChanges;
    }
    return _pendingChanges.where((change) {
      return change['facultyName'].toString().toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve Profile Changes'),
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
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search faculty name',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pending Profile Changes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredChanges.isEmpty
                        ? const Center(
                            child: Text('No pending changes found'),
                          )
                        : ListView.builder(
                            itemCount: filteredChanges.length,
                            itemBuilder: (context, index) {
                              final change = filteredChanges[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            change['facultyName'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            change['requestedDate'] ?? '',
                                            style: TextStyle(
                                                color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Department: ${change['department'] ?? ''}'),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Change Type: ${change['changeType'] ?? ''}'),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Old Value:'),
                                                Text(
                                                  change['oldValue'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('New Value:'),
                                                Text(
                                                  change['newValue'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => _rejectChange(
                                                change['facultyId']),
                                            child: const Text('Reject'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () => _approveChange(
                                                change['facultyId']),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF2A1070),
                                            ),
                                            child: const Text('Approve'),
                                          ),
                                        ],
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

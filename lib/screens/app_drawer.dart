// In lib/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:hr/screens/leaves/apply_leave_screen.dart';
import 'package:hr/screens/leaves/faculty_leave_approval_screen.dart';
import 'package:hr/screens/leaves/faculty_leave_balance_screen.dart';
import 'package:hr/screens/leaves/cancelled_leaves_screen.dart';
import 'package:hr/screens/leaves/leave_card_screen.dart';
import 'package:hr/screens/reports/combined_report_screen.dart';
import 'package:hr/screens/reports/particular_report_screen.dart';
import 'package:hr/screens/view_faculty_screen.dart';
import 'package:hr/screens/add/add_faculty_screen.dart';
import 'package:hr/screens/add/add_holiday_screen.dart';
import 'package:hr/screens/add/add_department_screen.dart';
import 'package:hr/screens/add/add_designation_screen.dart';
import 'package:hr/screens/reset_password_screen.dart';
import 'package:hr/screens/reports/report_tab.dart';
import 'package:hr/screens/faculty/approve_profile_change_screen.dart';
import 'package:hr/screens/faculty/update_hod_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _selectedDrawerItem;

  @override
  void initState() {
    super.initState();
    _selectedDrawerItem = 'Dashboard';
  }

  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required Widget destination,
    bool isExpanded = false,
    List<Widget>? children,
    int level = 0,
  }) {
    bool isSelected = _selectedDrawerItem == title;
    double horizontalPadding = 16.0 + (level * 16.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: isExpanded
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: horizontalPadding / 2,
              vertical: 4,
            ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isExpanded
          ? ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white70,
                  size: 20,
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              iconColor: Colors.white,
              collapsedIconColor: Colors.white70,
              backgroundColor: Colors.transparent,
              collapsedBackgroundColor: Colors.transparent,
              childrenPadding: EdgeInsets.only(left: horizontalPadding),
              onExpansionChanged: (isExpanding) {
                if (isExpanding) {
                  setState(() {
                    _selectedDrawerItem = title;
                  });
                }
              },
              children: children!.map((child) => child).toList(),
            )
          : ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white70,
                  size: 20,
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 8,
              ),
              onTap: () {
                setState(() {
                  _selectedDrawerItem = title;
                });
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => destination),
                  (route) => false,
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF6366F1),
      child: Column(
        children: [
          // Header
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Academate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'HR Management System',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Online',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // Dashboard
                _buildDrawerItem(
                  title: 'Dashboard',
                  icon: Icons.dashboard_rounded,
                  destination:
                      Container(), // Placeholder - will be handled by main navigation
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: Colors.white30, height: 1),
                ),

                // My Faculty
                _buildDrawerItem(
                  title: 'My Faculty',
                  icon: Icons.people_rounded,
                  destination: const ViewFacultyScreen(),
                  isExpanded: true,
                  children: [
                    _buildDrawerItem(
                      title: 'View Faculty',
                      icon: Icons.visibility_rounded,
                      destination: const ViewFacultyScreen(),
                      level: 1,
                    ),
                    _buildDrawerItem(
                      title: 'Approve Profile Change',
                      icon: Icons.approval_rounded,
                      destination: const ApproveProfileChangeScreen(),
                      level: 1,
                    ),
                    _buildDrawerItem(
                      title: 'Update HOD',
                      icon: Icons.admin_panel_settings_rounded,
                      destination: const UpdateHodScreen(),
                      level: 1,
                    ),
                  ],
                ),

                // Leaves
                _buildDrawerItem(
                  title: 'Leaves',
                  icon: Icons.event_note_rounded,
                  destination: const ApplyLeaveScreen(),
                  isExpanded: true,
                  children: [
                    _buildDrawerItem(
                      title: 'Apply Leave',
                      icon: Icons.add_circle_outline_rounded,
                      destination: const ApplyLeaveScreen(),
                      level: 1,
                    ),
                    _buildDrawerItem(
                      title: 'Leave Approval',
                      icon: Icons.approval_rounded,
                      destination: const FacultyLeaveApprovalScreen(),
                      level: 1,
                    ),
                    _buildDrawerItem(
                      title: 'Leave Balance',
                      icon: Icons.account_balance_wallet_rounded,
                      destination: const FacultyLeaveBalanceScreen(),
                      level: 1,
                    ),
                    _buildDrawerItem(
                      title: 'Cancelled Leaves',
                      icon: Icons.cancel_rounded,
                      destination: const CancelledLeavesScreen(),
                      level: 1,
                    ),
                    _buildDrawerItem(
                      title: 'Leave Card',
                      icon: Icons.credit_card_rounded,
                      destination: const LeaveCardScreen(),
                      level: 1,
                    ),
                  ],
                ),

                // Add
                _buildDrawerItem(
                  title: 'Add',
                  icon: Icons.add_circle_rounded,
                  destination: const AddFacultyScreen(),
                  isExpanded: true,
                  children: [
                    _buildDrawerItem(
                      title: 'Add Faculty',
                      icon: Icons.person_add_rounded,
                      destination: const AddFacultyScreen(),
                      level: 1,
                    ),
                    _buildDrawerItem(
                      title: 'Add Holiday',
                      icon: Icons.event_rounded,
                      destination: const AddHolidayScreen(),
                      level: 1,
                    ),
                    _buildDrawerItem(
                      title: 'Add Department',
                      icon: Icons.business_rounded,
                      destination: const AddDepartmentScreen(),
                      level: 1,
                    ),
                    _buildDrawerItem(
                      title: 'Add Designation',
                      icon: Icons.work_rounded,
                      destination: const AddDesignationScreen(),
                      level: 1,
                    ),
                  ],
                ),

                // Reports
                _buildDrawerItem(
                  title: 'Reports',
                  icon: Icons.analytics_rounded,
                  destination: const ReportTab(),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: Colors.white30, height: 1),
                ),

                // Settings
                _buildDrawerItem(
                  title: 'Reset Password',
                  icon: Icons.lock_reset_rounded,
                  destination: const ResetPasswordScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

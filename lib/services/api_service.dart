import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  static const String baseUrl =
      'https://api.test.vppcoe.getflytechnologies.com/api/hr';

  // Token management
  static const String _defaultToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOjMsInVzZXJfdHlwZSI6MSwicHJpdmlsZWdlIjpudWxsLCJpYXQiOjE3NDk2MzA4NDMsImV4cCI6MTc4MTE2Njg0M30.tradSsc3yRwF3uWPsODvkStgJwDDjGfY_1DDmY9muEc';
  static String? _token = _defaultToken;
  static const String _tokenKey = 'auth_token';

  // Initialize token from storage or use default
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey) ?? _defaultToken;
  }

  // Save token to storage
  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear token
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Headers with token
  static Map<String, String> get headers {
    print('Using token: $_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  static Map<String, dynamic> _getUserIdAndRoleFromToken() {
    if (_token != null && !JwtDecoder.isExpired(_token!)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      return {
        'uid': decodedToken['uid'],
        'user_type': decodedToken['user_type'],
      };
    } else {
      throw Exception('Invalid or expired token.');
    }
  }

  // Login method to get token
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['token'] != null) {
        await setToken(data['token']);
      }
      return data;
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  // Dashboard APIs
  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  // Leave Management APIs
  static Future<http.Response> getLeaveApprovals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaveApproval'),
      headers: headers,
    );
    print('Get Leave Approvals API Status: ${response.statusCode}');
    print('Get Leave Approvals API Body: ${response.body}');
    return response;
  }

  static Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveAppId,
    required String status,
    required String noOfDays,
    required String leaveId,
    required String facultyId,
  }) async {
    final tokenData = _getUserIdAndRoleFromToken();
    final uid = tokenData['uid'];
    final role = tokenData['user_type'];

    final body = json.encode({
      'app_id': leaveAppId,
      'status': status == 'Approved' ? 1 : 2, // 1 for Approved, 2 for Denied
      'no_of_days': noOfDays,
      'leave_id': leaveId,
      'faculty_id': facultyId,
      'role': role.toString(),
      'uid': uid.toString(),
    });
    print('Update Leave Status Request Body: $body');
    final response = await http.post(
      Uri.parse('$baseUrl/update_leave_status'),
      headers: headers,
      body: body,
    );
    print('Update Leave Status API Status: ${response.statusCode}');
    print('Update Leave Status API Body: ${response.body}');
    return json.decode(response.body);
  }

  static Future<http.Response> getApprovedLeaves({
    String? fromDate,
    String? toDate,
  }) async {
    String url = '$baseUrl/ApprovedLeaves';
    if (fromDate != null && toDate != null) {
      url += '?from_date=$fromDate&to_date=$toDate';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    print('Get Approved Leaves API Status: ${response.statusCode}');
    print('Get Approved Leaves API Body: ${response.body}');
    return response;
  }

  static Future<Map<String, dynamic>> getCancelledLeaves() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cancelled_leave'),
      headers: headers,
    );
    print('Cancelled Leaves API Raw Response: ${response.body}');
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getLeaveBalance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/FacultyLeaveBalance'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getFacultyLeaveBalance(
      {String? facultyId}) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/leaveBalance${facultyId != null ? '?faculty_id=$facultyId' : ''}'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateFacultyLeaveBalance({
    required String facultyId,
    required int cl,
    required int co,
    required int ml,
    required int el,
    required int sv,
    required int wv,
    required int sl,
    required int uel,
    required int mtl,
    required String remark,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/updateleaveBalance'),
      headers: headers,
      body: json.encode({
        'faculty_id': facultyId,
        'cl': cl,
        'co': co,
        'ml': ml,
        'el': el,
        'sv': sv,
        'wv': wv,
        'sl': sl,
        'uel': uel,
        'mtl': mtl,
        'remark': remark,
      }),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> generateLeaveCard({
    required String facultyId,
    required String year,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/generateLeaveCard?faculty_id=$facultyId&year=$year'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  // Faculty Management APIs
  static Future<Map<String, dynamic>> addFaculty({
    required String facultyClgId,
    required String name,
    required String contact,
    required int ftypeId,
    required int role,
    required int departId,
    required String joiningDate,
    required String email,
    required String password,
    required int shiftId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Add_Faculty'),
      headers: headers,
      body: json.encode({
        'faculty_clg_id': facultyClgId,
        'name': name,
        'contact': contact,
        'ftype_id': ftypeId,
        'role': role,
        'depart_id': departId,
        'joining_date': joiningDate,
        'email': email,
        'password': password,
        'shift_id': shiftId,
      }),
    );
    print('Add Faculty API Response: ${response.body}');
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getFacultyList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/myFaculty'),
      headers: headers,
    );
    print("faculty list response");
    print(response.body);

    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseData;
    } else {
      throw Exception('Failed to load faculty list: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> updateFacultyInfo({
    required String facultyId,
    required Map<String, dynamic> personalDetails,
    required Map<String, dynamic> academicDetails,
    required Map<String, dynamic> employmentDetails,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateFacultyinfo/$facultyId'),
      headers: headers,
      body: json.encode({
        'personal_details': personalDetails,
        'academic_details': academicDetails,
        'employment_details': employmentDetails,
      }),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> approveFacultyUpdate({
    required String facultyId,
    required String status,
    required String remarks,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/approveUpdate/$facultyId'),
      headers: headers,
      body: json.encode({
        'status': status,
        'remarks': remarks,
      }),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateUserType({
    required String facultyId,
    required String userType,
    required String role,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateUserType/$facultyId'),
      headers: headers,
      body: json.encode({
        'user_type': userType,
        'role': role,
      }),
    );
    return json.decode(response.body);
  }

  // Department Management APIs
  static Future<Map<String, dynamic>> addDepartment({
    required String name,
    required String code,
    required String hodId,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Add_department'),
      headers: headers,
      body: json.encode({
        'name': name,
        'code': code,
        'hod_id': hodId,
        'description': description,
      }),
    );
    print('Add Department API Status: ${response.statusCode}');
    print('Add Department API Body: ${response.body}');
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> addDesignation({
    required String name,
    String? code,
    String? description,
    String? grade,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Add_designation'),
      headers: headers,
      body: json.encode({
        'name': name,
        if (code != null) 'code': code,
        if (description != null) 'description': description,
        if (grade != null) 'grade': grade,
      }),
    );
    print(
        'Add Designation Request URL: ${Uri.parse('$baseUrl/Add_designation')}');
    print('Add Designation Request Headers: $headers');
    print('Add Designation Request Body: ${json.encode({
          'name': name,
          if (code != null) 'code': code,
          if (description != null) 'description': description,
          if (grade != null) 'grade': grade
        })}');
    print('Add Designation API Status: ${response.statusCode}');
    return json.decode(response.body);
  }

  // Get departments and related data
  static Future<Map<String, dynamic>> getDepartments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/add_faculty_get'),
      headers: headers,
    );
    print('Get Departments API Status: ${response.statusCode}');
    print('Get Departments API Body: ${response.body}');
    final data = json.decode(response.body);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception('Unexpected response format for getDepartments');
    }
  }

  static Future<List<Map<String, dynamic>>> getDesignations() async {
    try {
      final response = await getDepartments();
      if (response['role'] is List) {
        return List<Map<String, dynamic>>.from(response['role']);
      } else {
        throw Exception('Unexpected response format for designations');
      }
    } catch (e) {
      throw Exception('Failed to load designations: $e');
    }
  }

  // Delete faculty
  static Future<Map<String, dynamic>> deleteFaculty(String facultyId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deleteFac'),
      headers: headers,
      body: json.encode({'id': facultyId}),
    );
    return json.decode(response.body);
  }

  // Reports APIs
  static Future<Map<String, dynamic>> generateMonthlyReport({
    required String month,
    required String year,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/monthlyReport?month=$month&year=$year'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> generateFacultyReport({
    required String facultyId,
    required String fromDate,
    required String toDate,
  }) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/particularFacultyReport/$facultyId?from_date=$fromDate&to_date=$toDate'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<bool> downloadAllFaculty() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/downloadAllFaculty'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/faculty_report.csv';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print('Faculty report downloaded to: $filePath');
        return true;
      } else {
        print('Failed to download faculty report: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error downloading faculty report: $e');
      return false;
    }
  }

  // Holiday Management APIs
  static Future<Map<String, dynamic>> addHoliday({
    required String hname,
    String id = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addHoliday'),
      headers: headers,
      body: json.encode({
        'hname': hname,
        'id': id,
      }),
    );
    print('Add Holiday API Status: ${response.statusCode}');
    print('Add Holiday API Body: ${response.body}');
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getHolidayList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/addHoliday'),
      headers: headers,
    );
    print('Get Holiday List API Status: ${response.statusCode}');
    print('Get Holiday List API Body: ${response.body}');
    final responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['dateList'] is List) {
      return responseData['dateList'];
    } else {
      print('Error: Invalid or empty dateList in API response.');
      throw Exception(
          'Failed to load holidays: ${responseData['message'] ?? 'Unknown error'}');
    }
  }

  // Password Management APIs
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resetpass'),
      headers: headers,
      body: json.encode({
        'email': email,
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );
    return json.decode(response.body);
  }

  static Future<List<Map<String, dynamic>>> getAllFaculty() async {
    final response = await http.get(
      Uri.parse('$baseUrl/fetchAllFaculty'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['facultyList'] != null) {
        return List<Map<String, dynamic>>.from(data['facultyList']);
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load faculty list: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getShifts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/fetch_all_Shifts'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data['shifts'] is List) {
        return List<Map<String, dynamic>>.from(data['shifts']);
      } else if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Unexpected response format for shifts');
      }
    } else {
      throw Exception('Failed to load shifts: ${response.statusCode}');
    }
  }

  // Report APIs
  static Future<Map<String, dynamic>> getDailyAttendanceReport(
      {required String fromDate}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report/daily'),
      headers: headers,
      body: json.encode({'from_date': fromDate}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load daily attendance report: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getMonthlyAttendanceReport({
    required String startDate,
    required String endDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report/monthlyReport'),
      headers: headers,
      body: json.encode({'startDate': startDate, 'endDate': endDate}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load monthly attendance report: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getWorkingHoursReport({
    required String startDate,
    required String endDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report/workingHours'),
      headers: headers,
      body: json.encode({'startDate': startDate, 'endDate': endDate}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load working hours report: ${response.statusCode}');
    }
  }

  // Faculty Report APIs
  static Future<Map<String, dynamic>> getAllFacultyNames() async {
    final response = await http.get(
      Uri.parse('$baseUrl/facultyNames'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load faculty names: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getParticularFacultyAttendanceReport({
    required String facultyId,
    required String fromDate,
    required String toDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/particularFacultyAttendance'),
      headers: headers,
      body: json.encode({
        'facultyId': facultyId,
        'fromDate': fromDate,
        'toDate': toDate,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load particular faculty attendance report: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getParticularFacultyLeaveReport({
    required String facultyId,
    required String fromDate,
    required String toDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/particularFacultyLeaveReport'),
      headers: headers,
      body: json.encode({
        'facultyId': facultyId,
        'fromDate': fromDate,
        'toDate': toDate,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load particular faculty leave report: ${response.statusCode}');
    }
  }

  // Leave Card APIs
  static Future<Map<String, dynamic>> fetchAllFacultyIds() async {
    final response = await http.get(
      Uri.parse('$baseUrl/fetchAllFacultyIds'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load faculty IDs: ${response.statusCode}');
    }
  }

  static Future<http.Response> downloadFacultyLeaveReport({
    required String fromDate,
    required String toDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/downloadFacultyLeaveReport'),
      headers: {
        ...headers,
        'Accept': 'text/csv',
      },
      body: json.encode({
        'from_date': fromDate,
        'to_date': toDate,
      }),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception(
          'Failed to download faculty leave report: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> applyLeave({
    required String facultyId,
    required String fromDate,
    required String toDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/applyLeave'),
      headers: headers,
      body: json.encode({
        'faculty_id': facultyId,
        'from_date': fromDate,
        'to_date': toDate,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to apply leave: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getUpdateFaculty() async {
    final response = await http.get(
      Uri.parse('$baseUrl/getUpdateFaculty'),
      headers: headers,
    );
    print('Get Update Faculty API Status: ${response.statusCode}');
    print('Get Update Faculty API Body: ${response.body}');
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> postApproveUpdate({
    required String facultyId,
    String? status,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/postApproveUpdate'),
      headers: headers,
      body: json.encode({
        'faculty_id': facultyId,
        if (status != null) 'status': status,
      }),
    );
    print('Post Approve Update API Status: ${response.statusCode}');
    print('Post Approve Update API Body: ${response.body}');
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateFaculty(
      Map<String, dynamic> facultyData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_faculty.php'),
        body: facultyData,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAllDepartments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/add_faculty_get'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load departments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load departments: $e');
    }
  }

  static Future<Map<String, dynamic>> getHodByDepartment(
      String departmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getCurrentHod?depart_id=$departmentId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return decodedResponse['current_hod'] ?? {};
      } else {
        throw Exception('Failed to load HOD: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load HOD: $e');
    }
  }

  static Future<Map<String, dynamic>> updateHod({
    required String departmentId,
    required String facultyId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_hod.php'),
        body: {
          'department_id': departmentId,
          'faculty_id': facultyId,
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': e.toString()};
    }
  }
}

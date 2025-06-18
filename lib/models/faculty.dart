class Faculty {
  final String facultyClgId;
  final String name;
  final String contact;
  final int ftypeId;
  final String role;
  final int departId;
  final String joiningDate;
  final String email;
  final int shiftId;

  Faculty({
    required this.facultyClgId,
    required this.name,
    required this.contact,
    required this.ftypeId,
    required this.role,
    required this.departId,
    required this.joiningDate,
    required this.email,
    required this.shiftId,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      facultyClgId: json['faculty_clg_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      contact: json['contact']?.toString() ?? '',
      ftypeId: int.tryParse(json['ftype_id']?.toString() ?? '0') ?? 0,
      role: json['role']?.toString() ?? '',
      departId: int.tryParse(json['depart_id']?.toString() ?? '0') ?? 0,
      joiningDate: json['joining_date']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      shiftId: int.tryParse(json['shift_id']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'faculty_clg_id': facultyClgId,
      'name': name,
      'contact': contact,
      'ftype_id': ftypeId,
      'role': role,
      'depart_id': departId,
      'joining_date': joiningDate,
      'email': email,
      'shift_id': shiftId,
    };
  }
}

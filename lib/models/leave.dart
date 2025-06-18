class Leave {
  final String facultyId;
  final String leaveId;
  final String fromDate;
  final String toDate;
  final String reason;
  final int noOfDays;
  final String alternate;
  final String uid;
  final String doc;
  final String halfFullDay;

  Leave({
    required this.facultyId,
    required this.leaveId,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.noOfDays,
    required this.alternate,
    required this.uid,
    required this.doc,
    required this.halfFullDay,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      facultyId: json['faculty_id'] ?? '',
      leaveId: json['leave_id'] ?? '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
      reason: json['reason'] ?? '',
      noOfDays: json['no_of_days'] ?? 0,
      alternate: json['alternate'] ?? '',
      uid: json['uid'] ?? '',
      doc: json['doc'] ?? '',
      halfFullDay: json['half_full_day'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'faculty_id': facultyId,
      'leave_id': leaveId,
      'from_date': fromDate,
      'to_date': toDate,
      'reason': reason,
      'no_of_days': noOfDays,
      'alternate': alternate,
      'uid': uid,
      'doc': doc,
      'half_full_day': halfFullDay,
    };
  }
}

class LeaveBalance {
  final String facultyId;
  final int cl;
  final int co;
  final int ml;
  final int el;
  final int sv;
  final int wv;
  final int sl;
  final int uel;
  final int mtl;
  final String remark;

  LeaveBalance({
    required this.facultyId,
    required this.cl,
    required this.co,
    required this.ml,
    required this.el,
    required this.sv,
    required this.wv,
    required this.sl,
    required this.uel,
    required this.mtl,
    required this.remark,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      facultyId: json['faculty_id'] ?? '',
      cl: json['cl'] ?? 0,
      co: json['co'] ?? 0,
      ml: json['ml'] ?? 0,
      el: json['el'] ?? 0,
      sv: json['sv'] ?? 0,
      wv: json['wv'] ?? 0,
      sl: json['sl'] ?? 0,
      uel: json['uel'] ?? 0,
      mtl: json['mtl'] ?? 0,
      remark: json['remark'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
    };
  }
}

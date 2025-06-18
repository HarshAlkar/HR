class Department {
  final String id;
  final String name;

  Department({
    required this.id,
    required this.name,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['dpt_id']?.toString() ?? '',
      name: json['dname']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'id': id};
  }
}

class Designation {
  final String name;
  final String id;

  Designation({required this.name, required this.id});

  factory Designation.fromJson(Map<String, dynamic> json) {
    return Designation(name: json['name'] ?? '', id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'id': id};
  }
}

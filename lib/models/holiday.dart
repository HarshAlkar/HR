class Holiday {
  final String name;
  final String id;
  final String date;

  Holiday({required this.name, required this.id, required this.date});

  factory Holiday.fromJson(Map<String, dynamic> json) {
    final dynamic dateValue = json['date_value'];
    final dynamic idValue = json['id'];
    return Holiday(
      name: json['holidays'] ?? '',
      id: idValue != null ? idValue.toString() : '',
      date: dateValue != null ? dateValue.toString() : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'hname': name, 'id': id, 'date': date};
  }
}

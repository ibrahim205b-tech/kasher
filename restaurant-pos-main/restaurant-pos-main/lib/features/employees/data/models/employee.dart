enum PayType {
  daily,
  weekly,
  monthly,
}

extension PayTypeExtension on PayType {
  String get nameArabic {
    switch (this) {
      case PayType.daily:
        return 'يومي';
      case PayType.weekly:
        return 'أسبوعي';
      case PayType.monthly:
        return 'شهري';
    }
  }
}

class Employee {
  final String id;
  final String name;
  final String role;
  final String phone;
  final double salary;
  final PayType payType;
  final DateTime? lastPaidAt;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.salary,
    this.payType = PayType.monthly,
    this.lastPaidAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'phone': phone,
      'salary': salary,
      'pay_type': payType.name,
      'last_paid_at': lastPaidAt?.toIso8601String(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      phone: map['phone'] as String,
      salary: (map['salary'] as num).toDouble(),
      payType: PayType.values.firstWhere(
        (e) => e.name == map['pay_type'],
        orElse: () => PayType.monthly,
      ),
      lastPaidAt: map['last_paid_at'] != null
          ? DateTime.parse(map['last_paid_at'] as String)
          : null,
    );
  }

  Employee copyWith({
    String? id,
    String? name,
    String? role,
    String? phone,
    double? salary,
    PayType? payType,
    DateTime? lastPaidAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      salary: salary ?? this.salary,
      payType: payType ?? this.payType,
      lastPaidAt: lastPaidAt ?? this.lastPaidAt,
    );
  }
}

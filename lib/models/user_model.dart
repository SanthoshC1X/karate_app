class UserModel {
  final String id;
  final String name;
  final int? age;
  final String beltLevel;
  final String? phone;
  final String role; // 'admin' or 'student'
  final String? locationId;
  final DateTime createdAt;

  static const List<String> beltLevels = [
    'White',
    'Yellow',
    'Orange',
    'Green',
    'Blue',
    'Brown',
    'Black',
  ];

  UserModel({
    required this.id,
    required this.name,
    this.age,
    required this.beltLevel,
    this.phone,
    required this.role,
    this.locationId,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int?,
      beltLevel: map['belt_level'] as String? ?? 'White',
      phone: map['phone'] as String?,
      role: map['role'] as String? ?? 'student',
      locationId: map['location_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'belt_level': beltLevel,
      'phone': phone,
      'role': role,
      'location_id': locationId,
    };
  }

  UserModel copyWith({
    String? name,
    int? age,
    String? beltLevel,
    String? phone,
    String? locationId,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      beltLevel: beltLevel ?? this.beltLevel,
      phone: phone ?? this.phone,
      role: role,
      locationId: locationId ?? this.locationId,
      createdAt: createdAt,
    );
  }
}

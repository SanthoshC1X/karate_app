class UserModel {
  final String id;
  final String name;
  final String? email;
  final int? age;
  final String beltLevel;
  final String? phone;
  final String role; // 'admin' or 'student'
  final String member; // 'student' | 'master' | 'super_admin'
  final String? locationId;
  final List<String> masterIds;
  final List<String> locationIds;
  final List<String> classIds;
  final List<String> masterClassIds;
  final String? bio;
  final String? profilePictureUrl;
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
    this.email,
    this.age,
    required this.beltLevel,
    this.phone,
    required this.role,
    String? member,
    this.locationId,
    this.masterIds = const [],
    this.locationIds = const [],
    this.classIds = const [],
    this.masterClassIds = const [],
    this.bio,
    this.profilePictureUrl,
    required this.createdAt,
  }) : member = member ??
            (role == 'super_admin'
                ? 'super_admin'
                : role == 'admin'
                    ? 'master'
                    : 'student');

  bool get isAdmin => member == 'master' || member == 'super_admin';
  bool get isMaster => member == 'master';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      age: map['age'] as int?,
      beltLevel: map['belt_level'] as String? ?? 'White',
      phone: map['phone'] as String?,
      role: map['role'] as String? ?? 'student',
      member: map['member'] as String?,
      locationId: map['location_id'] as String?,
      masterIds: (map['master_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      classIds: (map['class_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      masterClassIds: (map['master_class_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      locationIds: (map['location_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      bio: map['bio'] as String?,
      profilePictureUrl: map['profile_picture_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'belt_level': beltLevel,
      'phone': phone,
      'role': role,
      'member': member,
      'location_id': locationId,
      'master_ids': masterIds,
      'class_ids': classIds,
      'master_class_ids': masterClassIds,
      'location_ids': locationIds,
      'bio': bio,
      'profile_picture_url': profilePictureUrl,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    int? age,
    String? beltLevel,
    String? phone,
    String? member,
    String? locationId,
    List<String>? masterIds,
    List<String>? classIds,
    List<String>? masterClassIds,
    List<String>? locationIds,
    String? bio,
    String? profilePictureUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      beltLevel: beltLevel ?? this.beltLevel,
      phone: phone ?? this.phone,
      role: role,
      member: member,
      locationId: locationId ?? this.locationId,
      masterIds: masterIds ?? this.masterIds,
      classIds: classIds ?? this.classIds,
      masterClassIds: masterClassIds ?? this.masterClassIds,
      locationIds: locationIds ?? this.locationIds,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt,
    );
  }
}

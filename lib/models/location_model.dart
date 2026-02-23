class LocationModel {
  final String id;
  final String name;
  final String? address;
  final String? notes;
  final DateTime createdAt;

  LocationModel({
    required this.id,
    required this.name,
    this.address,
    this.notes,
    required this.createdAt,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'notes': notes,
    };
  }

  LocationModel copyWith({
    String? name,
    String? address,
    String? notes,
  }) {
    return LocationModel(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

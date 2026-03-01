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
    final createdAtRaw = map['created_at'] ?? map['createdAt'];
    return LocationModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      address: map['address']?.toString(),
      notes: map['notes']?.toString(),
      createdAt: createdAtRaw is String
          ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
          : DateTime.now(),
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

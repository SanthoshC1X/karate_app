import 'api_client.dart';

class ClassOption {
  final String id;
  final String name;
  final String? description;

  const ClassOption({
    required this.id,
    required this.name,
    this.description,
  });

  factory ClassOption.fromMap(Map<String, dynamic> map) {
    return ClassOption(
      id: map['id'].toString(),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
    );
  }
}

class ClassRankField {
  final String id;
  final String classId;
  final String masterId;
  final String masterName;
  final String fieldLabel;
  final String fieldType; // "text" | "select"
  final List<String> options;
  final int orderIndex;

  const ClassRankField({
    required this.id,
    required this.classId,
    required this.masterId,
    required this.masterName,
    required this.fieldLabel,
    required this.fieldType,
    required this.options,
    required this.orderIndex,
  });

  factory ClassRankField.fromMap(Map<String, dynamic> map) {
    return ClassRankField(
      id: map['id'].toString(),
      classId: map['class_id'].toString(),
      masterId: map['master_id'].toString(),
      masterName: map['master_name']?.toString() ?? '',
      fieldLabel: map['field_label']?.toString() ?? '',
      fieldType: map['field_type']?.toString() ?? 'text',
      options: (map['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      orderIndex: (map['order_index'] as num?)?.toInt() ?? 0,
    );
  }
}

class ClassService {
  final _api = ApiClient.instance;

  Future<List<ClassOption>> getClasses({
    List<String>? masterIds,
    String search = '',
  }) async {
    final query = <String, String>{};
    if (masterIds != null && masterIds.isNotEmpty) {
      query['master_ids'] = masterIds.join(',');
    }
    if (search.trim().isNotEmpty) query['search'] = search.trim();

    final data = await _api.get('/users/classes/public', query: query);
    final list = data is List ? data : const [];
    return list
        .whereType<Map>()
        .map((item) => ClassOption.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ClassRankField>> getRankFields({
    required List<String> classIds,
    required List<String> masterIds,
  }) async {
    if (classIds.isEmpty || masterIds.isEmpty) return const [];

    final data = await _api.get('/users/classes/rank-fields', query: {
      'class_ids': classIds.join(','),
      'master_ids': masterIds.join(','),
    });
    final list = data is List ? data : const [];
    return list
        .whereType<Map>()
        .map((item) =>
            ClassRankField.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}

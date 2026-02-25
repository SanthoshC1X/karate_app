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
}

import 'api_client.dart';

class MasterOption {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final List<String> locationIds;

  const MasterOption({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.locationIds = const [],
  });

  factory MasterOption.fromMap(Map<String, dynamic> map) {
    return MasterOption(
      id: map['id'].toString(),
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString(),
      phone: map['phone']?.toString(),
      locationIds: (map['location_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class MasterService {
  final _api = ApiClient.instance;

  Future<List<MasterOption>> searchMasters(String query) async {
    final data = await _api.get('/users/masters/public', query: {
      'search': query,
      'limit': '20',
    });

    final list = data is List ? data : const [];
    return list
        .whereType<Map>()
        .map((item) => MasterOption.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<MasterOption> createMaster({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final data = await _api.post('/users/masters/public', body: {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
    });

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid master response');
    }

    return MasterOption.fromMap(data);
  }
}

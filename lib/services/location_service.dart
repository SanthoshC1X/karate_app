import '../models/location_model.dart';
import 'api_client.dart';

class LocationService {
  final _api = ApiClient.instance;

  Future<List<LocationModel>> getLocations() async {
    final data = await _api.get('/locations');
    final list = _extractList(data);
    return list
        .whereType<Map>()
        .map((item) => LocationModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<LocationModel> addLocation({
    required String name,
    String? address,
    String? notes,
  }) async {
    final data = await _api.post('/locations', body: {
      'name': name,
      'address': address,
      'notes': notes,
    });

    final map = _extractMap(data);
    return LocationModel.fromMap(map);
  }

  Future<void> updateLocation(String id, Map<String, dynamic> updates) async {
    await _api.patch('/locations/$id', body: updates);
  }

  Future<void> deleteLocation(String id) async {
    await _api.delete('/locations/$id');
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic>) {
      final wrapped = data['data'] ?? data['locations'] ?? data['items'];
      if (wrapped is List<dynamic>) return wrapped;
    }
    throw Exception('Invalid locations response');
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final wrapped = data['data'] ?? data['location'];
      if (wrapped is Map<String, dynamic>) return wrapped;
      return data;
    }
    throw Exception('Invalid location response');
  }
}

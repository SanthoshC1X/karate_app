import '../models/location_model.dart';
import 'api_client.dart';

class LocationService {
  final _api = ApiClient.instance;

  Future<List<LocationModel>> getLocations() async {
    final data = await _api.get('/locations') as List<dynamic>;
    return data
        .map((item) => LocationModel.fromMap(item as Map<String, dynamic>))
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
    }) as Map<String, dynamic>;
    return LocationModel.fromMap(data);
  }

  Future<void> updateLocation(String id, Map<String, dynamic> updates) async {
    await _api.patch('/locations/$id', body: updates);
  }

  Future<void> deleteLocation(String id) async {
    await _api.delete('/locations/$id');
  }
}


import '../models/location_model.dart';
import 'mock_api_store.dart';

class LocationService {
  final _store = MockApiStore.instance;

  Future<List<LocationModel>> getLocations() async {
    final data = await _store.getLocations();
    return data.map(LocationModel.fromMap).toList();
  }

  Future<LocationModel> addLocation({
    required String name,
    String? address,
    String? notes,
  }) async {
    final data = await _store.addLocation(
      name: name,
      address: address,
      notes: notes,
    );
    return LocationModel.fromMap(data);
  }

  Future<void> updateLocation(String id, Map<String, dynamic> updates) async {
    await _store.updateLocation(id, updates);
  }

  Future<void> deleteLocation(String id) async {
    await _store.deleteLocation(id);
  }
}

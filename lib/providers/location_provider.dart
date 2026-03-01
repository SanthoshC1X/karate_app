import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _service;

  LocationProvider({LocationService? service})
      : _service = service ?? LocationService();

  List<LocationModel> _locations = const [];
  bool _isLoading = false;
  String? _error;

  List<LocationModel> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLocations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _locations = await _service.getLocations();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLocation({
    required String name,
    String? address,
    String? notes,
  }) async {
    _error = null;
    notifyListeners();
    try {
      await _service.addLocation(name: name, address: address, notes: notes);
      await fetchLocations();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateLocation(String id, Map<String, dynamic> updates) async {
    _error = null;
    notifyListeners();
    try {
      await _service.updateLocation(id, updates);
      await fetchLocations();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteLocation(String id) async {
    _error = null;
    notifyListeners();
    try {
      await _service.deleteLocation(id);
      await fetchLocations();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}

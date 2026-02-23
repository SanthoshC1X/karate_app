import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());

final locationsProvider = FutureProvider<List<LocationModel>>((ref) async {
  return ref.read(locationServiceProvider).getLocations();
});

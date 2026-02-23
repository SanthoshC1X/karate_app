import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

final allStudentsProvider = FutureProvider<List<UserModel>>((ref) async {
  return ref.read(userServiceProvider).getAllStudents();
});

final studentsByLocationProvider =
    FutureProvider.family<List<UserModel>, String>((ref, locationId) async {
  return ref.read(userServiceProvider).getStudentsByLocation(locationId);
});

final studentDetailProvider =
    FutureProvider.family<UserModel?, String>((ref, studentId) async {
  return ref.read(userServiceProvider).getStudentById(studentId);
});

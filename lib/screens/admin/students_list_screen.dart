import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../providers/location_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/belt_badge.dart';
import '../../widgets/common/app_skeleton_loading.dart';
import '../../widgets/common/step_card.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  String _searchQuery = '';
  LocationModel? _selectedLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();
      final locationProvider = context.read<LocationProvider>();
      await userProvider.fetchAllStudents();
      await locationProvider.fetchLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final locationProvider = context.watch<LocationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Students',
          style: AppText.titleMd.copyWith(color: AppColors.textOnDark),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search students...',
                hintStyle: const TextStyle(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.field,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          const SizedBox(height: 10),
          if (locationProvider.isLoading)
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  AppSkeletonLoading(width: 70, height: 32),
                  SizedBox(width: 8),
                  AppSkeletonLoading(width: 90, height: 32),
                  SizedBox(width: 8),
                  AppSkeletonLoading(width: 90, height: 32),
                ],
              ),
            )
          else
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedLocation == null,
                      onSelected: (_) => setState(() => _selectedLocation = null),
                      selectedColor: AppColors.primary.withValues(alpha: 0.3),
                      labelStyle: TextStyle(
                        color: _selectedLocation == null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...locationProvider.locations.map(
                    (loc) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(loc.name),
                        selected: _selectedLocation?.id == loc.id,
                        onSelected: (_) => setState(
                          () => _selectedLocation =
                              _selectedLocation?.id == loc.id ? null : loc,
                        ),
                        selectedColor: AppColors.primary.withValues(alpha: 0.3),
                        labelStyle: TextStyle(
                          color: _selectedLocation?.id == loc.id
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: userProvider.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: 7,
                    itemBuilder: (_, __) => const AppSkeletonListItem(),
                  )
                : userProvider.error != null
                    ? Center(
                        child: Text(
                          'Error: ${userProvider.error}',
                          style: const TextStyle(color: AppColors.error),
                        ),
                      )
                    : Builder(
                        builder: (_) {
                          var filtered = userProvider.students;
                          if (_selectedLocation != null) {
                            filtered = filtered
                                .where((s) => s.locationId == _selectedLocation!.id)
                                .toList();
                          }
                          if (_searchQuery.isNotEmpty) {
                            filtered = filtered
                                .where(
                                  (s) => s.name.toLowerCase().contains(_searchQuery) ||
                                      (s.phone?.contains(_searchQuery) ?? false),
                                )
                                .toList();
                          }
                          if (filtered.isEmpty) {
                            return const Center(
                              child: Text(
                                'No students found',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            );
                          }
                          return RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () => context.read<UserProvider>().fetchAllStudents(),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final student = filtered[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: StepCard(
                                    icon: Icons.person,
                                    title: student.name,
                                    subtitle: student.age != null
                                        ? 'Age ${student.age}'
                                        : 'Student',
                                    color: AppColors.primary,
                                    trailing: BeltBadge(
                                      beltLevel: student.beltLevel,
                                      size: 11,
                                    ),
                                    onTap: () => context.go('/admin/students/${student.id}'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

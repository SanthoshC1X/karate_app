import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../providers/location_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_skeleton_loading.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/step_card.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().fetchLocations();
    });
  }

  Future<void> _showLocationDialog({LocationModel? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          existing == null ? 'Add Location' : 'Edit Location',
          style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textOnDark),
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  labelStyle: TextStyle(color: AppColors.textOnDark54),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressCtrl,
                style: const TextStyle(color: AppColors.textOnDark),
                decoration: const InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: AppColors.textOnDark54),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: notesCtrl,
                style: const TextStyle(color: AppColors.textOnDark),
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  labelStyle: TextStyle(color: AppColors.textOnDark54),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textOnDark54)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              try {
                final provider = context.read<LocationProvider>();
                if (existing == null) {
                  await provider.addLocation(
                    name: nameCtrl.text.trim(),
                    address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                    notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  );
                } else {
                  await provider.updateLocation(existing.id, {
                    'name': nameCtrl.text.trim(),
                    'address': addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                    'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  });
                }
              } catch (e) {
                if (mounted) {
                  AppSnackbar.show(
                    context: context,
                    type: AppSnackbarType.error,
                    title: 'Save Failed',
                    message: e.toString(),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLocation(LocationModel loc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Location', style: TextStyle(color: AppColors.textOnDark)),
        content: Text(
          'Delete "${loc.name}"? This cannot be undone.',
          style: const TextStyle(color: AppColors.textOnDark70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textOnDark54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    await context.read<LocationProvider>().deleteLocation(loc.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Locations', style: AppText.titleMd.copyWith(color: AppColors.textOnDark)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLocationDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.onPrimary),
        label: const Text('Add Location',
            style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.bold)),
      ),
      body: provider.isLoading
          ? const _LocationsSkeleton()
          : provider.error != null
              ? Center(
                  child: Text('Error: ${provider.error}',
                      style: const TextStyle(color: AppColors.error)),
                )
              : provider.locations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.location_off, size: 64, color: AppColors.textOnDark30),
                          SizedBox(height: 16),
                          Text('No locations yet',
                              style: TextStyle(color: AppColors.textOnDark54, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Tap + to add your first location',
                              style: TextStyle(color: AppColors.textOnDark30, fontSize: 13)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => context.read<LocationProvider>().fetchLocations(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: provider.locations.length,
                        itemBuilder: (_, i) {
                          final loc = provider.locations[i];
                          return Dismissible(
                            key: Key(loc.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: AppColors.dangerDeep,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete_outline,
                                  color: AppColors.onDanger, size: 28),
                            ),
                            confirmDismiss: (_) async {
                              await _deleteLocation(loc);
                              return false;
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: StepCard(
                                icon: Icons.location_on,
                                title: loc.name,
                                subtitle: loc.address ?? 'No address',
                                color: AppColors.primary,
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.textOnDark38,
                                  ),
                                  onPressed: () => _showLocationDialog(existing: loc),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _LocationsSkeleton extends StatelessWidget {
  const _LocationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: 7,
      itemBuilder: (_, __) => const AppSkeletonListItem(),
    );
  }
}

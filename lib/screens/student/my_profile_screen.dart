import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/location_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/belt_badge.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/app_skeleton_loading.dart';
import '../../widgets/common/app_buttons.dart';
import '../../widgets/loading_overlay.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  UserModel? _profile;
  bool _loading = true;
  bool _saving = false;
  bool _editing = false;

  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedBelt = 'White';
  LocationModel? _selectedLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<LocationProvider>().fetchLocations();
      await _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.loadProfile();
      if (!mounted) return;
      final profile = authProvider.currentUser;
      if (mounted) {
        setState(() {
          _profile = profile;
          if (profile != null) {
            _nameCtrl.text = profile.name;
            _ageCtrl.text = profile.age?.toString() ?? '';
            _phoneCtrl.text = profile.phone ?? '';
            _selectedBelt = profile.beltLevel;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final uid = context.read<AuthProvider>().currentUserId;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await context.read<UserProvider>().updateStudent(uid, {
        'name': _nameCtrl.text.trim(),
        'age': int.tryParse(_ageCtrl.text),
        'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        'belt_level': _selectedBelt,
        'location_id': _selectedLocation?.id ?? _profile?.locationId,
      });
      await _loadProfile();
      if (mounted) {
        setState(() => _editing = false);
        AppSnackbar.show(
          context: context,
          type: AppSnackbarType.success,
          title: 'Success',
          message: 'Profile updated successfully.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context: context,
          type: AppSnackbarType.error,
          title: 'Error',
          message: '$e',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: _MyProfileSkeleton(),
      );
    }

    return LoadingOverlay(
      isLoading: _saving,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('My Profile',
              style: AppText.titleMd.copyWith(color: AppColors.textOnDark)),
          actions: [
            IconButton(
              icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
              onPressed: () => setState(() => _editing = !_editing),
            ),
            if (_editing)
              TextButton(
                onPressed: _save,
                child: const Text('Save',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        body: _profile == null
            ? const Center(
                child: Text('No profile found',
                    style: TextStyle(color: AppColors.textSecondary)))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _profile!.name[0].toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 38,
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(child: BeltBadge(beltLevel: _profile!.beltLevel)),
                  const SizedBox(height: 28),
                  if (!_editing) ...[
                    _ProfileInfoCard(profile: _profile!),
                  ] else ...[
                    // Edit form
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: AppColors.textOnDark),
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: AppColors.textOnDark54),
                        prefixIcon: Icon(Icons.person_outline,
                            color: AppColors.textOnDark38),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textOnDark),
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        labelStyle: TextStyle(color: AppColors.textOnDark54),
                        prefixIcon: Icon(Icons.cake_outlined,
                            color: AppColors.textOnDark38),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppColors.textOnDark),
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        labelStyle: TextStyle(color: AppColors.textOnDark54),
                        prefixIcon: Icon(Icons.phone_outlined,
                            color: AppColors.textOnDark38),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppDropdown<String>(
                      hint: 'Select belt level',
                      value: _selectedBelt,
                      items: UserModel.beltLevels,
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedBelt = v);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    if (locationProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: AppSkeletonLoading(height: 46, width: double.infinity),
                      )
                    else if (locationProvider.error != null)
                      const SizedBox()
                    else
                      AppDropdown<LocationModel>(
                        hint: 'Select Location',
                        value: _selectedLocation ??
                            locationProvider.locations
                                .where((l) => l.id == _profile!.locationId)
                                .firstOrNull,
                        items: locationProvider.locations,
                        itemLabel: (l) => l.name,
                        onChanged: (v) => setState(() => _selectedLocation = v),
                      ),
                    const SizedBox(height: 28),
                    AppLoadingButton(
                      label: 'Save Changes',
                      isLoading: _saving,
                      onPressed: _save,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _MyProfileSkeleton extends StatelessWidget {
  const _MyProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Center(
          child: AppSkeletonLoading(
            width: 90,
            height: 90,
            borderRadius: BorderRadius.all(Radius.circular(45)),
          ),
        ),
        SizedBox(height: 12),
        Center(child: AppSkeletonLoading(width: 90, height: 22)),
        SizedBox(height: 28),
        AppSkeletonLoading(height: 160, width: double.infinity),
      ],
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final UserModel profile;
  const _ProfileInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _Row(icon: Icons.person, label: 'Name', value: profile.name),
          const Divider(color: AppColors.borderLight),
          _Row(
              icon: Icons.cake_outlined,
              label: 'Age',
              value: profile.age?.toString() ?? 'Not set'),
          const Divider(color: AppColors.borderLight),
          _Row(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: profile.phone ?? 'Not set'),
          const Divider(color: AppColors.borderLight),
          _Row(
              icon: Icons.sports_martial_arts,
              label: 'Belt',
              value: profile.beltLevel),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }
}




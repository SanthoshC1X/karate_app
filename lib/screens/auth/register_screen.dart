import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/location_model.dart';
import '../../models/user_model.dart';
import '../../providers/location_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/class_service.dart';
import '../../services/master_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../widgets/common/app_skeleton_loading.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/app_buttons.dart';
import '../../widgets/loading_overlay.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _masterSearchCtrl = TextEditingController();
  final _classSearchCtrl = TextEditingController();
  final _locationSearchCtrl = TextEditingController();
  final MasterService _masterService = MasterService();
  final ClassService _classService = ClassService();
  String _selectedBelt = 'White';
  String? _selectedLocationId;
  final Map<String, MasterOption> _selectedMasters = {};
  final Map<String, ClassOption> _selectedClasses = {};
  List<MasterOption> _masterOptions = const [];
  List<ClassOption> _classOptions = const [];
  bool _obscure = true;
  bool _loading = false;
  bool _locationsLoading = true;
  bool _mastersLoading = true;
  bool _classesLoading = false;
  bool _mastersExpanded = false;
  bool _classesExpanded = false;
  bool _locationsExpanded = false;
  String? _locationsError;
  String? _mastersError;
  String? _classesError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.fetchLocations();
      await _loadMasters('');
      if (!mounted) return;
      setState(() {
        _locationsLoading = locationProvider.isLoading;
        _locationsError = locationProvider.error;
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    _masterSearchCtrl.dispose();
    _classSearchCtrl.dispose();
    _locationSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMasters(String query) async {
    setState(() {
      _mastersLoading = true;
      _mastersError = null;
    });
    try {
      final list = await _masterService.searchMasters(query);
      if (!mounted) return;
      setState(() => _masterOptions = list);
    } catch (e) {
      if (!mounted) return;
      setState(
          () => _mastersError = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _mastersLoading = false);
    }
  }

  Future<void> _refreshClassesForSelectedMasters() async {
    final masterIds = _selectedMasters.keys.toList();
    if (masterIds.isEmpty) {
      if (!mounted) return;
      setState(() {
        _classOptions = const [];
        _selectedClasses.clear();
        _classSearchCtrl.clear();
        _classesError = null;
        _classesLoading = false;
        _classesExpanded = false;
      });
      return;
    }

    setState(() {
      _classesLoading = true;
      _classesError = null;
    });
    try {
      final list = await _classService.getClasses(masterIds: masterIds);
      if (!mounted) return;
      final validClassIds = list.map((c) => c.id).toSet();
      setState(() {
        _classOptions = list;
        _selectedClasses.removeWhere((id, _) => !validClassIds.contains(id));
      });
    } catch (e) {
      if (!mounted) return;
      setState(
          () => _classesError = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _classesLoading = false);
    }
  }

  Future<void> _toggleMasterSelection(MasterOption master) async {
    setState(() {
      if (_selectedMasters.containsKey(master.id)) {
        _selectedMasters.remove(master.id);
      } else {
        _selectedMasters[master.id] = master;
      }
    });
    await _refreshClassesForSelectedMasters();
  }

  Future<void> _removeMasterSelection(String masterId) async {
    setState(() => _selectedMasters.remove(masterId));
    await _refreshClassesForSelectedMasters();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocationId == null) {
      AppSnackbar.show(
        context: context,
        type: AppSnackbarType.pending,
        title: 'Location Required',
        message: 'Please select your location.',
      );
      return;
    }
    if (_selectedMasters.isEmpty) {
      AppSnackbar.show(
        context: context,
        type: AppSnackbarType.pending,
        title: 'Master Required',
        message: 'Please select at least one master.',
      );
      return;
    }
    if (_selectedClasses.isEmpty) {
      AppSnackbar.show(
        context: context,
        type: AppSnackbarType.pending,
        title: 'Class Required',
        message: 'Please select at least one class.',
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().signUp(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            name: _nameCtrl.text.trim(),
            age: int.tryParse(_ageCtrl.text),
            beltLevel: _selectedBelt,
            phone:
                _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
            locationId: _selectedLocationId,
            masterIds: _selectedMasters.keys.toList(),
            classIds: _selectedClasses.keys.toList(),
          );
      if (!mounted) return;
      context.go('/student/home');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context: context,
        type: AppSnackbarType.error,
        title: 'Registration Failed',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationProvider = context.watch<LocationProvider>();
    final locations = locationProvider.locations;
    final selectedMasterLocationIds =
        _selectedMasters.values.expand((m) => m.locationIds).toSet();
    final List<LocationModel> filteredLocations =
        selectedMasterLocationIds.isEmpty
            ? const <LocationModel>[]
            : locations
                .where((loc) => selectedMasterLocationIds.contains(loc.id))
                .toList();
    final visibleMasters = _masterOptions.where((m) {
      final q = _masterSearchCtrl.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      return m.name.toLowerCase().contains(q) ||
          (m.email?.toLowerCase().contains(q) ?? false);
    }).toList();
    final visibleLocations = filteredLocations.where((loc) {
      final q = _locationSearchCtrl.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      return loc.name.toLowerCase().contains(q) ||
          (loc.address?.toLowerCase().contains(q) ?? false);
    }).toList();
    final visibleClasses = _classOptions.where((classOption) {
      final q = _classSearchCtrl.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      return classOption.name.toLowerCase().contains(q) ||
          (classOption.description?.toLowerCase().contains(q) ?? false);
    }).toList();
    if (_selectedLocationId != null &&
        filteredLocations.every((loc) => loc.id != _selectedLocationId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedLocationId = null);
      });
    }

    return LoadingOverlay(
      isLoading: _loading,
      message: 'Creating account...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Create Account'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Student Registration',
                  style: AppText.titleMd.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in your details to join the dojo',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),
                // Name
                TextFormField(
                  controller: _nameCtrl,
                  style: AppText.body,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon:
                        Icon(Icons.person_outline, color: AppColors.textHint),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),
                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: AppText.body,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon:
                        Icon(Icons.email_outlined, color: AppColors.textHint),
                  ),
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 14),
                // Password
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  style: AppText.body,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.textHint),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textHint,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 14),
                // Age
                TextFormField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  style: AppText.body,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon:
                        Icon(Icons.cake_outlined, color: AppColors.textHint),
                  ),
                ),
                const SizedBox(height: 14),
                // Phone
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: AppText.body,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon:
                        Icon(Icons.phone_outlined, color: AppColors.textHint),
                  ),
                ),
                const SizedBox(height: 14),
                // Belt level
                AppDropdown<String>(
                  hint: 'Belt Level',
                  value: _selectedBelt,
                  items: UserModel.beltLevels,
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedBelt = v);
                    }
                  },
                ),
                const SizedBox(height: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      setState(() => _mastersExpanded = !_mastersExpanded),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Search Masters *',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      prefixIcon: Icon(Icons.search, color: AppColors.textHint),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedMasters.isEmpty
                                ? 'Select one or more masters'
                                : _selectedMasters.values
                                    .map((m) => m.name)
                                    .join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body.copyWith(
                              color: _selectedMasters.isEmpty
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          _mastersExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.textHint,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_mastersExpanded)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 230),
                    decoration: BoxDecoration(
                      color: AppColors.field,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            controller: _masterSearchCtrl,
                            decoration: InputDecoration(
                              hintText: 'Search masters...',
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    _loadMasters(_masterSearchCtrl.text.trim()),
                                icon: const Icon(Icons.refresh,
                                    color: AppColors.textHint),
                              ),
                            ),
                            onChanged: (v) {
                              _loadMasters(v.trim());
                              setState(() {});
                            },
                          ),
                        ),
                        Expanded(
                          child: _mastersLoading
                              ? const AppSkeletonLoading(
                                  height: 80,
                                  width: double.infinity,
                                )
                              : _mastersError != null
                                  ? Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        'Failed to load masters: $_mastersError',
                                        style: const TextStyle(
                                            color: AppColors.error),
                                      ),
                                    )
                                  : visibleMasters.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No masters found.',
                                            style: TextStyle(
                                                color: AppColors.textSecondary),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: visibleMasters.length,
                                          itemBuilder: (_, i) {
                                            final master = visibleMasters[i];
                                            final selected = _selectedMasters
                                                .containsKey(master.id);
                                            return CheckboxListTile(
                                              value: selected,
                                              onChanged: (_) =>
                                                  _toggleMasterSelection(
                                                      master),
                                              title: Text(master.name),
                                              subtitle: master.email == null
                                                  ? null
                                                  : Text(master.email!),
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .trailing,
                                            );
                                          },
                                        ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedMasters.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedMasters.values
                          .map(
                            (master) => Chip(
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.2),
                              label: Text(master.name),
                              onDeleted: () =>
                                  _removeMasterSelection(master.id),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      setState(() => _classesExpanded = !_classesExpanded),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Classes *',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      prefixIcon:
                          Icon(Icons.class_outlined, color: AppColors.textHint),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedClasses.isEmpty
                                ? 'Select one or more classes'
                                : _selectedClasses.values
                                    .map((c) => c.name)
                                    .join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body.copyWith(
                              color: _selectedClasses.isEmpty
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          _classesExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.textHint,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_classesExpanded)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 230),
                    decoration: BoxDecoration(
                      color: AppColors.field,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            controller: _classSearchCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Search classes...',
                              prefixIcon:
                                  Icon(Icons.search, color: AppColors.textHint),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        Expanded(
                          child: _selectedMasters.isEmpty
                              ? Center(
                                  child: Text(
                                    'Select master(s) first to view mapped classes.',
                                    style: AppText.s.copyWith(
                                        color: AppColors.textSecondary),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : _classesLoading
                                  ? const AppSkeletonLoading(
                                      height: 80,
                                      width: double.infinity,
                                    )
                                  : _classesError != null
                                      ? Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(
                                            'Failed to load classes: $_classesError',
                                            style: const TextStyle(
                                                color: AppColors.error),
                                          ),
                                        )
                                      : visibleClasses.isEmpty
                                          ? const Center(
                                              child: Text(
                                                'No classes found for selected master(s).',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .textSecondary),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: visibleClasses.length,
                                              itemBuilder: (_, i) {
                                                final classOption =
                                                    visibleClasses[i];
                                                final selected =
                                                    _selectedClasses
                                                        .containsKey(
                                                            classOption.id);
                                                return CheckboxListTile(
                                                  value: selected,
                                                  onChanged: (_) {
                                                    setState(() {
                                                      if (selected) {
                                                        _selectedClasses.remove(
                                                            classOption.id);
                                                      } else {
                                                        _selectedClasses[
                                                                classOption
                                                                    .id] =
                                                            classOption;
                                                      }
                                                    });
                                                  },
                                                  title: Text(classOption.name),
                                                  subtitle:
                                                      classOption.description ==
                                                              null
                                                          ? null
                                                          : Text(classOption
                                                              .description!),
                                                  controlAffinity:
                                                      ListTileControlAffinity
                                                          .trailing,
                                                );
                                              },
                                            ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedClasses.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedClasses.values
                          .map(
                            (classOption) => Chip(
                              backgroundColor:
                                  AppColors.info.withValues(alpha: 0.2),
                              label: Text(classOption.name),
                              onDeleted: () => setState(() =>
                                  _selectedClasses.remove(classOption.id)),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      setState(() => _locationsExpanded = !_locationsExpanded),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Location *',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      prefixIcon: Icon(Icons.location_on_outlined,
                          color: AppColors.textHint),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedLocationId == null
                                ? 'Select location'
                                : filteredLocations
                                    .firstWhere(
                                        (loc) => loc.id == _selectedLocationId)
                                    .name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body.copyWith(
                              color: _selectedLocationId == null
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          _locationsExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.textHint,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_locationsLoading || locationProvider.isLoading)
                  const AppSkeletonLoading(
                    height: 46,
                    width: double.infinity,
                  )
                else if ((_locationsError ?? locationProvider.error) != null)
                  Text(
                    'Failed to load locations: ${_locationsError ?? locationProvider.error}',
                    style: const TextStyle(color: AppColors.error),
                  )
                else if (_locationsExpanded)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: AppColors.field,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            controller: _locationSearchCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Search locations...',
                              prefixIcon:
                                  Icon(Icons.search, color: AppColors.textHint),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        Expanded(
                          child: filteredLocations.isEmpty
                              ? Center(
                                  child: Text(
                                    'Select master(s) first to view mapped locations.',
                                    style: AppText.s.copyWith(
                                        color: AppColors.textSecondary),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : visibleLocations.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No locations found.',
                                        style: TextStyle(
                                            color: AppColors.textSecondary),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: visibleLocations.length,
                                      itemBuilder: (_, i) {
                                        final loc = visibleLocations[i];
                                        return RadioListTile<String>(
                                          value: loc.id,
                                          groupValue: _selectedLocationId,
                                          title: Text(loc.name),
                                          subtitle: loc.address == null
                                              ? null
                                              : Text(loc.address!),
                                          onChanged: (v) {
                                            setState(() {
                                              _selectedLocationId = v;
                                              _locationsExpanded = false;
                                            });
                                          },
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                AppLoadingButton(
                  label: 'Create Account',
                  isLoading: _loading,
                  onPressed: _register,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text('Login', style: AppText.cta),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../services/class_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_skeleton_loading.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/loading_overlay.dart';

class RegisterMasterScreen extends StatefulWidget {
  const RegisterMasterScreen({super.key});

  @override
  State<RegisterMasterScreen> createState() => _RegisterMasterScreenState();
}

class _RegisterMasterScreenState extends State<RegisterMasterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final Set<String> _selectedLocationIds = {};
  final Set<String> _selectedClassIds = {};
  final ClassService _classService = ClassService();
  final List<ClassOption> _classOptions = [];
  bool _classesLoading = true;
  String? _classesError;
  final List<TextEditingController> _newLocationNameCtrls = [];
  final List<TextEditingController> _newLocationAddressCtrls = [];
  final List<TextEditingController> _newLocationNotesCtrls = [];
  final List<TextEditingController> _newClassNameCtrls = [];
  final List<TextEditingController> _newClassDescCtrls = [];
  bool _obscure = true;
  bool _loading = false;
  bool _locationsLoading = true;
  String? _locationsError;

  @override
  void initState() {
    super.initState();
    _addNewLocationInput(notify: false);
    _addNewClassInput(notify: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.fetchLocations();
      await _loadClasses();
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
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    for (final c in _newLocationNameCtrls) {
      c.dispose();
    }
    for (final c in _newLocationAddressCtrls) {
      c.dispose();
    }
    for (final c in _newLocationNotesCtrls) {
      c.dispose();
    }
    for (final c in _newClassNameCtrls) {
      c.dispose();
    }
    for (final c in _newClassDescCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addNewLocationInput({bool notify = true}) {
    if (notify) {
      setState(() {
        _newLocationNameCtrls.add(TextEditingController());
        _newLocationAddressCtrls.add(TextEditingController());
        _newLocationNotesCtrls.add(TextEditingController());
      });
    } else {
      _newLocationNameCtrls.add(TextEditingController());
      _newLocationAddressCtrls.add(TextEditingController());
      _newLocationNotesCtrls.add(TextEditingController());
    }
  }

  Future<void> _loadClasses() async {
    setState(() {
      _classesLoading = true;
      _classesError = null;
    });
    try {
      final list = await _classService.getClasses();
      if (!mounted) return;
      setState(() {
        _classOptions
          ..clear()
          ..addAll(list);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _classesError = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _classesLoading = false);
    }
  }

  void _addNewClassInput({bool notify = true}) {
    if (notify) {
      setState(() {
        _newClassNameCtrls.add(TextEditingController());
        _newClassDescCtrls.add(TextEditingController());
      });
    } else {
      _newClassNameCtrls.add(TextEditingController());
      _newClassDescCtrls.add(TextEditingController());
    }
  }

  void _removeNewClassInput(int index) {
    if (_newClassNameCtrls.length == 1) {
      _newClassNameCtrls[index].clear();
      _newClassDescCtrls[index].clear();
      return;
    }
    setState(() {
      _newClassNameCtrls.removeAt(index).dispose();
      _newClassDescCtrls.removeAt(index).dispose();
    });
  }

  void _removeNewLocationInput(int index) {
    if (_newLocationNameCtrls.length == 1) {
      _newLocationNameCtrls[index].clear();
      _newLocationAddressCtrls[index].clear();
      _newLocationNotesCtrls[index].clear();
      return;
    }
    setState(() {
      _newLocationNameCtrls.removeAt(index).dispose();
      _newLocationAddressCtrls.removeAt(index).dispose();
      _newLocationNotesCtrls.removeAt(index).dispose();
    });
  }

  Future<void> _registerMaster() async {
    if (!_formKey.currentState!.validate()) return;
    final newLocations = <Map<String, String?>>[];
    for (var i = 0; i < _newLocationNameCtrls.length; i++) {
      final name = _newLocationNameCtrls[i].text.trim();
      if (name.isEmpty) continue;
      newLocations.add({
        'name': name,
        'address': _newLocationAddressCtrls[i].text.trim().isEmpty
            ? null
            : _newLocationAddressCtrls[i].text.trim(),
        'notes': _newLocationNotesCtrls[i].text.trim().isEmpty
            ? null
            : _newLocationNotesCtrls[i].text.trim(),
      });
    }
    final newClasses = <Map<String, String?>>[];
    for (var i = 0; i < _newClassNameCtrls.length; i++) {
      final name = _newClassNameCtrls[i].text.trim();
      if (name.isEmpty) continue;
      newClasses.add({
        'name': name,
        'description': _newClassDescCtrls[i].text.trim().isEmpty
            ? null
            : _newClassDescCtrls[i].text.trim(),
      });
    }

    if (_selectedLocationIds.isEmpty && newLocations.isEmpty) {
      AppSnackbar.show(
        context: context,
        type: AppSnackbarType.pending,
        title: 'Location Required',
        message: 'Add or select at least one work location.',
      );
      return;
    }
    if (_selectedClassIds.isEmpty && newClasses.isEmpty) {
      AppSnackbar.show(
        context: context,
        type: AppSnackbarType.pending,
        title: 'Class Required',
        message: 'Add or select at least one class.',
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().signUpMaster(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        locationIds: _selectedLocationIds.toList(),
        newLocations: newLocations,
        classIds: _selectedClassIds.toList(),
        newClasses: newClasses,
      );
      if (!mounted) return;
      context.go('/admin/dashboard');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context: context,
        type: AppSnackbarType.error,
        title: 'Master Registration Failed',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final locations = locationProvider.locations;

    return LoadingOverlay(
      isLoading: _loading,
      message: 'Creating master account...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Master Registration'),
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
                  'Create Master Account',
                  style: AppText.titleMd.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  'Register as a master and select your locations.',
                  style: AppText.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bioCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Select Locations *',
                  style: AppText.r.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add your work location(s). You can add as many as you want.',
                  style: AppText.s.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                if (_locationsLoading || locationProvider.isLoading)
                  const AppSkeletonLoading(height: 80, width: double.infinity)
                else if ((_locationsError ?? locationProvider.error) != null)
                  Text(
                    'Failed to load locations: ${_locationsError ?? locationProvider.error}',
                    style: const TextStyle(color: AppColors.error),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: locations
                        .map(
                          (loc) => FilterChip(
                            label: Text(loc.name),
                            selected: _selectedLocationIds.contains(loc.id),
                            selectedColor: AppColors.primary.withValues(alpha: 0.22),
                            onSelected: (_) {
                              setState(() {
                                if (_selectedLocationIds.contains(loc.id)) {
                                  _selectedLocationIds.remove(loc.id);
                                } else {
                                  _selectedLocationIds.add(loc.id);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Select Classes *',
                  style: AppText.r.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add classes like Yoga, Karate, Silambu etc. You can add many.',
                  style: AppText.s.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                if (_classesLoading)
                  const AppSkeletonLoading(height: 80, width: double.infinity)
                else if (_classesError != null)
                  Text(
                    'Failed to load classes: $_classesError',
                    style: const TextStyle(color: AppColors.error),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _classOptions
                        .map(
                          (cls) => FilterChip(
                            label: Text(cls.name),
                            selected: _selectedClassIds.contains(cls.id),
                            selectedColor: AppColors.primary.withValues(alpha: 0.22),
                            onSelected: (_) {
                              setState(() {
                                if (_selectedClassIds.contains(cls.id)) {
                                  _selectedClassIds.remove(cls.id);
                                } else {
                                  _selectedClassIds.add(cls.id);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Add Class',
                      style: AppText.r.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _addNewClassInput,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add More'),
                    ),
                  ],
                ),
                ...List.generate(_newClassNameCtrls.length, (i) {
                  return Card(
                    color: AppColors.surface,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Class ${i + 1}', style: AppText.r),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _removeNewClassInput(i),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: _newClassNameCtrls[i],
                            decoration: const InputDecoration(
                              labelText: 'Class Name',
                              prefixIcon: Icon(Icons.class_outlined),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _newClassDescCtrls[i],
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              alignLabelWithHint: true,
                              prefixIcon: Icon(Icons.description_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Add Work Location',
                      style: AppText.r.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _addNewLocationInput,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add More'),
                    ),
                  ],
                ),
                ...List.generate(_newLocationNameCtrls.length, (i) {
                  return Card(
                    color: AppColors.surface,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Location ${i + 1}', style: AppText.r),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _removeNewLocationInput(i),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: _newLocationNameCtrls[i],
                            decoration: const InputDecoration(
                              labelText: 'Location Name',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _newLocationAddressCtrls[i],
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              prefixIcon: Icon(Icons.home_work_outlined),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _newLocationNotesCtrls[i],
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              alignLabelWithHint: true,
                              prefixIcon: Icon(Icons.notes_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _registerMaster,
                  child: const Text('Create Master Account'),
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

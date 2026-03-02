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
import '../../widgets/common/app_buttons.dart';
import '../../widgets/loading_overlay.dart';

// ── Local helper ─────────────────────────────────────────────────────────────

class _RankFieldEntry {
  final TextEditingController labelCtrl;
  final TextEditingController optionInputCtrl;
  String fieldType = 'text'; // "text" | "select"
  List<String> options;

  _RankFieldEntry({String label = '', List<String>? options})
      : labelCtrl = TextEditingController(text: label),
        optionInputCtrl = TextEditingController(),
        options = options ?? [];

  void dispose() {
    labelCtrl.dispose();
    optionInputCtrl.dispose();
  }

  Map<String, dynamic> toMap(int index) => {
        'field_label': labelCtrl.text.trim(),
        'field_type': fieldType,
        'options': options,
        'order_index': index,
      };
}

// ── Screen ───────────────────────────────────────────────────────────────────

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
  final Map<String, String> _selectedClassNames = {};
  final ClassService _classService = ClassService();
  final List<ClassOption> _classOptions = [];
  bool _classesLoading = true;
  String? _classesError;
  final List<TextEditingController> _newLocationNameCtrls = [];
  final List<TextEditingController> _newLocationAddressCtrls = [];
  final List<TextEditingController> _newLocationNotesCtrls = [];
  final List<TextEditingController> _newClassNameCtrls = [];
  final List<TextEditingController> _newClassDescCtrls = [];

  // Rank fields for existing selected classes (keyed by class_id)
  final Map<String, List<_RankFieldEntry>> _existingClassRankFields = {};
  // Rank fields for new class entries (parallel to _newClassNameCtrls)
  final List<List<_RankFieldEntry>> _newClassRankFields = [];
  // Which existing-class rank sections are expanded
  final Set<String> _expandedRankSections = {};

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
    for (final c in _newLocationNameCtrls) { c.dispose(); }
    for (final c in _newLocationAddressCtrls) { c.dispose(); }
    for (final c in _newLocationNotesCtrls) { c.dispose(); }
    for (final c in _newClassNameCtrls) { c.dispose(); }
    for (final c in _newClassDescCtrls) { c.dispose(); }
    for (final fields in _existingClassRankFields.values) {
      for (final f in fields) { f.dispose(); }
    }
    for (final fields in _newClassRankFields) {
      for (final f in fields) { f.dispose(); }
    }
    super.dispose();
  }

  // ── Location helpers ───────────────────────────────────────────────────────

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

  // ── Class helpers ──────────────────────────────────────────────────────────

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
      setState(
          () => _classesError = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _classesLoading = false);
    }
  }

  void _addNewClassInput({bool notify = true}) {
    if (notify) {
      setState(() {
        _newClassNameCtrls.add(TextEditingController());
        _newClassDescCtrls.add(TextEditingController());
        _newClassRankFields.add([]);
      });
    } else {
      _newClassNameCtrls.add(TextEditingController());
      _newClassDescCtrls.add(TextEditingController());
      _newClassRankFields.add([]);
    }
  }

  void _removeNewClassInput(int index) {
    if (_newClassNameCtrls.length == 1) {
      _newClassNameCtrls[index].clear();
      _newClassDescCtrls[index].clear();
      setState(() {
        for (final f in _newClassRankFields[index]) { f.dispose(); }
        _newClassRankFields[index] = [];
      });
      return;
    }
    setState(() {
      _newClassNameCtrls.removeAt(index).dispose();
      _newClassDescCtrls.removeAt(index).dispose();
      final removed = _newClassRankFields.removeAt(index);
      for (final f in removed) { f.dispose(); }
    });
  }

  // ── Rank field helpers ─────────────────────────────────────────────────────

  void _addRankFieldToExisting(String classId) {
    setState(() {
      _existingClassRankFields.putIfAbsent(classId, () => []);
      _existingClassRankFields[classId]!.add(_RankFieldEntry());
    });
  }

  void _removeRankFieldFromExisting(String classId, int index) {
    setState(() {
      _existingClassRankFields[classId]!.removeAt(index).dispose();
    });
  }

  void _addRankFieldToNew(int classIndex) {
    setState(() => _newClassRankFields[classIndex].add(_RankFieldEntry()));
  }

  void _removeRankFieldFromNew(int classIndex, int fieldIndex) {
    setState(() {
      _newClassRankFields[classIndex].removeAt(fieldIndex).dispose();
    });
  }

  void _addOptionToField(_RankFieldEntry entry) {
    final opt = entry.optionInputCtrl.text.trim();
    if (opt.isEmpty) return;
    setState(() {
      entry.options.add(opt);
      entry.optionInputCtrl.clear();
    });
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

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

    final newClasses = <Map<String, dynamic>>[];
    for (var i = 0; i < _newClassNameCtrls.length; i++) {
      final name = _newClassNameCtrls[i].text.trim();
      if (name.isEmpty) continue;
      final rankFields = _newClassRankFields[i]
          .asMap()
          .entries
          .where((e) => e.value.labelCtrl.text.trim().isNotEmpty)
          .map((e) => e.value.toMap(e.key))
          .toList();
      newClasses.add({
        'name': name,
        'description': _newClassDescCtrls[i].text.trim().isEmpty
            ? null
            : _newClassDescCtrls[i].text.trim(),
        if (rankFields.isNotEmpty) 'rank_fields': rankFields,
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

    // Build rank fields map for existing selected classes
    final classRankFields = <String, List<Map<String, dynamic>>>{};
    for (final classId in _selectedClassIds) {
      final fields = _existingClassRankFields[classId] ?? [];
      final valid = fields
          .asMap()
          .entries
          .where((e) => e.value.labelCtrl.text.trim().isNotEmpty)
          .map((e) => e.value.toMap(e.key))
          .toList();
      if (valid.isNotEmpty) classRankFields[classId] = valid;
    }

    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().signUpMaster(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        name: _nameCtrl.text.trim(),
        phone:
            _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        locationIds: _selectedLocationIds.toList(),
        newLocations: newLocations,
        classIds: _selectedClassIds.toList(),
        newClasses: newClasses,
        classRankFields:
            classRankFields.isNotEmpty ? classRankFields : null,
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

  // ── Rank field UI builders ─────────────────────────────────────────────────

  Widget _buildRankFieldRow({
    required _RankFieldEntry entry,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: entry.labelCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Field Name',
                  hintText: 'e.g. Standard, Medium',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: entry.fieldType,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'text', child: Text('Text')),
                DropdownMenuItem(value: 'select', child: Text('Select')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => entry.fieldType = v);
              },
            ),
            IconButton(
              onPressed: onRemove,
              icon:
                  const Icon(Icons.close, size: 18, color: AppColors.error),
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
        if (entry.fieldType == 'select') ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.options.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: entry.options
                        .asMap()
                        .entries
                        .map((e) => Chip(
                              label:
                                  Text(e.value, style: AppText.s),
                              deleteIcon:
                                  const Icon(Icons.close, size: 14),
                              onDeleted: () => setState(
                                  () => entry.options.removeAt(e.key)),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entry.optionInputCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Add option (e.g. CBSE)',
                          isDense: true,
                        ),
                        onSubmitted: (_) => _addOptionToField(entry),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _addOptionToField(entry),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const Divider(height: 20, color: AppColors.borderLight),
      ],
    );
  }

  Widget _buildExistingClassRankSection(String classId, String className) {
    final fields = _existingClassRankFields[classId] ?? [];
    final expanded = _expandedRankSections.contains(classId);

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() {
              if (expanded) {
                _expandedRankSections.remove(classId);
              } else {
                _expandedRankSections.add(classId);
                _existingClassRankFields.putIfAbsent(classId, () => []);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.leaderboard_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(className, style: AppText.r)),
                  if (fields.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${fields.length} field${fields.length == 1 ? '' : 's'}',
                        style: AppText.s
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14)
                  .copyWith(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 10),
                  ...fields.asMap().entries.map((e) =>
                      _buildRankFieldRow(
                        entry: e.value,
                        onRemove: () =>
                            _removeRankFieldFromExisting(classId, e.key),
                      )),
                  TextButton.icon(
                    onPressed: () =>
                        _addRankFieldToExisting(classId),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Field'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewClassRankSection(int classIndex) {
    final fields = _newClassRankFields[classIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Rank Fields',
              style: AppText.s.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _addRankFieldToNew(classIndex),
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Field'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        if (fields.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Text(
              'Optional — leave empty for no ranking',
              style: AppText.s.copyWith(color: AppColors.textHint),
            ),
          )
        else
          ...fields.asMap().entries.map((e) => _buildRankFieldRow(
                entry: e.value,
                onRemove: () =>
                    _removeRankFieldFromNew(classIndex, e.key),
              )),
      ],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
                  style:
                      AppText.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6
                      ? 'Min 6 characters'
                      : null,
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

                // ── Locations ─────────────────────────────────────────────────
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
                  style:
                      AppText.s.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                if (_locationsLoading || locationProvider.isLoading)
                  const AppSkeletonLoading(
                      height: 80, width: double.infinity)
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
                            selected:
                                _selectedLocationIds.contains(loc.id),
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.22),
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

                // ── Select existing classes ────────────────────────────────────
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
                  style:
                      AppText.s.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                if (_classesLoading)
                  const AppSkeletonLoading(
                      height: 80, width: double.infinity)
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
                            selected:
                                _selectedClassIds.contains(cls.id),
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.22),
                            onSelected: (_) {
                              setState(() {
                                if (_selectedClassIds.contains(cls.id)) {
                                  _selectedClassIds.remove(cls.id);
                                  _selectedClassNames.remove(cls.id);
                                  _expandedRankSections.remove(cls.id);
                                } else {
                                  _selectedClassIds.add(cls.id);
                                  _selectedClassNames[cls.id] = cls.name;
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),

                // ── Rank fields for existing selected classes ──────────────────
                if (_selectedClassIds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.leaderboard_outlined,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Define Rankings (Optional)',
                        style: AppText.r.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a class to define fields students fill in at registration. Leave empty for classes with no ranking (e.g. Swimming).',
                    style: AppText.s.copyWith(color: AppColors.textHint),
                  ),
                  const SizedBox(height: 10),
                  ..._selectedClassIds.map((classId) {
                    final name =
                        _selectedClassNames[classId] ?? classId;
                    return _buildExistingClassRankSection(classId, name);
                  }),
                ],

                const SizedBox(height: 12),

                // ── Add new classes ────────────────────────────────────────────
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Class ${i + 1}', style: AppText.r),
                              const Spacer(),
                              IconButton(
                                onPressed: () =>
                                    _removeNewClassInput(i),
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
                              prefixIcon:
                                  Icon(Icons.description_outlined),
                            ),
                          ),
                          _buildNewClassRankSection(i),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // ── Add new locations ──────────────────────────────────────────
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
                              Text('Location ${i + 1}',
                                  style: AppText.r),
                              const Spacer(),
                              IconButton(
                                onPressed: () =>
                                    _removeNewLocationInput(i),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: _newLocationNameCtrls[i],
                            decoration: const InputDecoration(
                              labelText: 'Location Name',
                              prefixIcon:
                                  Icon(Icons.location_on_outlined),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _newLocationAddressCtrls[i],
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              prefixIcon:
                                  Icon(Icons.home_work_outlined),
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
                AppLoadingButton(
                  label: 'Create Master Account',
                  isLoading: _loading,
                  onPressed: _registerMaster,
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

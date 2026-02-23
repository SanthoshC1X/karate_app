import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/location_model.dart';
import '../../models/user_model.dart';
import '../../providers/location_provider.dart';
import '../../services/attendance_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/step_card.dart';
import '../../widgets/common/app_skeleton_loading.dart';
import '../../widgets/belt_badge.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/common/app_snackbar.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  ConsumerState<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  int _step = 0; // 0=pick location, 1=pick date, 2=mark students
  LocationModel? _location;
  DateTime _date = DateTime.now();
  List<UserModel> _students = [];
  Map<String, bool> _presenceMap = {};
  bool _loading = false;
  bool _saving = false;

  Future<void> _loadStudents() async {
    if (_location == null) return;
    setState(() => _loading = true);
    try {
      final students =
          await UserService().getStudentsByLocation(_location!.id);
      // Pre-fill existing attendance for this date
      final existing = await AttendanceService()
          .getAttendanceByDateAndLocation(
              locationId: _location!.id, date: _date);
      final existingMap = {for (final a in existing) a.studentId: a.isPresent};
      setState(() {
        _students = students;
        _presenceMap = {
          for (final s in students)
            s.id: existingMap[s.id] ?? false
        };
      });
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
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await AttendanceService().markAttendance(
        locationId: _location!.id,
        date: _date,
        studentPresenceMap: _presenceMap,
      );
      if (!mounted) return;
      AppSnackbar.show(
        context: context,
        type: AppSnackbarType.success,
        title: 'Success',
        message: 'Attendance saved successfully.',
      );
      setState(() {
        _step = 0;
        _location = null;
        _students = [];
        _presenceMap = {};
        _date = DateTime.now();
      });
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryDark,
            surface: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(locationsProvider);

    return LoadingOverlay(
      isLoading: _saving,
      message: 'Saving attendance...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Mark Attendance',
              style: AppText.titleMd.copyWith(color: AppColors.textOnDark)),
        ),
        body: Column(
          children: [
            // Step indicator
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(3, (i) {
                  final active = i == _step;
                  final done = i < _step;
                  return Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done
                                ? AppColors.success
                                : active
                                    ? AppColors.primary
                                    : AppColors.borderLight,
                          ),
                          child: Center(
                            child: done
                                ? const Icon(Icons.check,
                                    color: AppColors.textOnDark, size: 16)
                                : Text('${i + 1}',
                                    style: TextStyle(
                                      color: active
                                          ? AppColors.textOnDark
                                          : AppColors.textOnDark38,
                                      fontWeight: FontWeight.bold,
                                    )),
                          ),
                        ),
                        if (i < 2)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: done ? AppColors.success : AppColors.borderLight,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: _step == 0
                  ? _StepLocation(
                      locationsAsync: locationsAsync,
                      onSelect: (loc) async {
                        setState(() {
                          _location = loc;
                          _step = 1;
                        });
                      },
                    )
                  : _step == 1
                      ? _StepDate(
                          date: _date,
                          onPickDate: _pickDate,
                          onNext: () async {
                            setState(() => _step = 2);
                            await _loadStudents();
                          },
                          onBack: () => setState(() => _step = 0),
                        )
                      : _loading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: _MarkStudentsSkeleton(),
                            )
                          : _StepMark(
                              students: _students,
                              presenceMap: _presenceMap,
                              onToggle: (id, v) =>
                                  setState(() => _presenceMap[id] = v),
                              onSave: _save,
                              onBack: () => setState(() => _step = 1),
                              date: _date,
                              location: _location!,
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepLocation extends StatelessWidget {
  final AsyncValue<List<LocationModel>> locationsAsync;
  final Function(LocationModel) onSelect;
  const _StepLocation({required this.locationsAsync, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return locationsAsync.when(
      loading: () => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (_, __) => const AppSkeletonListItem(),
      ),
      error: (e, _) =>
          Center(child: Text('$e', style: TextStyle(color: AppColors.error))),
      data: (locations) {
        if (locations.isEmpty) {
          return const Center(
              child: Text('No locations found. Add one first.',
                  style: TextStyle(color: AppColors.textOnDark54)));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Step 1: Select Location',
                  style: AppText.section.copyWith(color: AppColors.textOnDark)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: locations.length,
                itemBuilder: (_, i) {
                  final loc = locations[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: StepCard(
                      icon: Icons.location_on,
                      title: loc.name,
                      subtitle: 'Tap to continue',
                      color: AppColors.primary,
                      onTap: () => onSelect(loc),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MarkStudentsSkeleton extends StatelessWidget {
  const _MarkStudentsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => const AppSkeletonListItem(height: 76),
    );
  }
}

class _StepDate extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPickDate;
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _StepDate(
      {required this.date,
      required this.onPickDate,
      required this.onNext,
      required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 2: Select Date',
              style: AppText.section.copyWith(color: AppColors.textOnDark)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onPickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha:0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: 16),
                  Text(
                    DateFormat('EEEE, MMMM d yyyy').format(date),
                    style: const TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textOnDark54,
                    side: const BorderSide(color: AppColors.borderMuted),
                    minimumSize: const Size(100, 48)),
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  child: const Text('Load Students'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepMark extends StatelessWidget {
  final List<UserModel> students;
  final Map<String, bool> presenceMap;
  final Function(String, bool) onToggle;
  final VoidCallback onSave;
  final VoidCallback onBack;
  final DateTime date;
  final LocationModel location;

  const _StepMark({
    required this.students,
    required this.presenceMap,
    required this.onToggle,
    required this.onSave,
    required this.onBack,
    required this.date,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Step 3: Mark Attendance',
                style: AppText.section.copyWith(color: AppColors.textOnDark)),
            const SizedBox(height: 32),
            const Icon(Icons.people_outline, size: 64, color: AppColors.textOnDark30),
            const SizedBox(height: 16),
            const Text('No students at this location',
                style: TextStyle(color: AppColors.textOnDark54)),
            const Spacer(),
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textOnDark54,
                  side: const BorderSide(color: AppColors.borderMuted),
                  minimumSize: const Size(double.infinity, 48)),
              child: const Text('Back'),
            ),
          ],
        ),
      );
    }
    final presentCount = presenceMap.values.where((v) => v).length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step 3: Mark Attendance',
                  style: AppText.section.copyWith(color: AppColors.textOnDark)),
              const SizedBox(height: 4),
              Text(
                '${location.name} • ${DateFormat('MMM d').format(date)} • $presentCount/${students.length} present',
                style: const TextStyle(color: AppColors.textOnDark54, fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: students.length,
            itemBuilder: (_, i) {
              final s = students[i];
              final isPresent = presenceMap[s.id] ?? false;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPresent
                        ? AppColors.success.withValues(alpha:0.4)
                        : AppColors.borderLighter,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPresent
                        ? AppColors.success.withValues(alpha:0.2)
                        : AppColors.borderLight,
                    child: Text(
                      s.name[0].toUpperCase(),
                      style: TextStyle(
                          color: isPresent ? AppColors.success : AppColors.textOnDark38,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(s.name,
                      style: const TextStyle(
                          color: AppColors.textOnDark, fontWeight: FontWeight.w600)),
                  subtitle: BeltBadge(beltLevel: s.beltLevel, size: 11),
                  trailing: Switch(
                    value: isPresent,
                    onChanged: (v) => onToggle(s.id, v),
                    activeThumbColor: AppColors.success,
                    activeTrackColor: AppColors.success.withValues(alpha:0.3),
                    inactiveThumbColor: AppColors.error,
                    inactiveTrackColor: AppColors.error.withValues(alpha:0.2),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textOnDark54,
                    side: const BorderSide(color: AppColors.borderMuted),
                    minimumSize: const Size(100, 48)),
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Attendance'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}




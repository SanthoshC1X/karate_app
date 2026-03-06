import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _service;

  PaymentProvider({PaymentService? service})
      : _service = service ?? PaymentService();

  bool _isLoading = false;
  String? _error;

  // Master: keyed by "year-month"
  final Map<String, List<StudentPaymentOverview>> _overview = {};
  // Master: keyed by studentId
  final Map<String, List<PaymentMonthEntry>> _studentHistory = {};
  // Student
  List<PaymentMonthEntry> _myPayments = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PaymentMonthEntry> get myPayments => _myPayments;

  List<StudentPaymentOverview> getOverview(int year, int month) =>
      _overview['$year-$month'] ?? const [];

  List<PaymentMonthEntry> getStudentHistory(String studentId) =>
      _studentHistory[studentId] ?? const [];

  // ── Master ──────────────────────────────────────────────────────────────

  Future<void> fetchMasterOverview({required int year, required int month}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _overview['$year-$month'] =
          await _service.getMasterMonthOverview(year: year, month: month);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStudentYearHistory({
    required String studentId,
    required int year,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _studentHistory[studentId] = await _service.getStudentYearHistory(
        studentId: studentId,
        year: year,
      );
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePayment({
    required String studentId,
    required int year,
    required int month,
  }) async {
    try {
      final updated = await _service.togglePayment(
        studentId: studentId,
        year: year,
        month: month,
      );
      // Patch overview cache
      final key = '$year-$month';
      final list = _overview[key];
      if (list != null) {
        final idx = list.indexWhere((e) => e.studentId == studentId);
        if (idx >= 0) {
          _overview[key] = List.of(list)
            ..[idx] = StudentPaymentOverview(
              studentId: list[idx].studentId,
              studentName: list[idx].studentName,
              beltLevel: list[idx].beltLevel,
              profilePictureUrl: list[idx].profilePictureUrl,
              payment: updated,
            );
        }
      }
      // Patch history cache
      final history = _studentHistory[studentId];
      if (history != null) {
        final idx = history.indexWhere((e) => e.month == month && e.year == year);
        if (idx >= 0) {
          _studentHistory[studentId] = List.of(history)
            ..[idx] = PaymentMonthEntry(month: month, year: year, payment: updated);
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> masterSaveReceipt({
    required String studentId,
    required int year,
    required int month,
    required String receiptUrl,
  }) async {
    try {
      final updated = await _service.masterSaveReceipt(
        studentId: studentId,
        year: year,
        month: month,
        receiptUrl: receiptUrl,
      );
      _patchHistoryCache(studentId: studentId, year: year, month: month, record: updated);
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // ── Student ─────────────────────────────────────────────────────────────

  Future<void> fetchMyPayments({required int year}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _myPayments = await _service.getMyPayments(year: year);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveMyReceipt({
    required int year,
    required int month,
    required String receiptUrl,
  }) async {
    try {
      final updated = await _service.saveMyReceipt(
        year: year,
        month: month,
        receiptUrl: receiptUrl,
      );
      final idx = _myPayments.indexWhere((e) => e.month == month && e.year == year);
      if (idx >= 0) {
        _myPayments = List.of(_myPayments)
          ..[idx] = PaymentMonthEntry(month: month, year: year, payment: updated);
      } else {
        _myPayments = [
          ..._myPayments,
          PaymentMonthEntry(month: month, year: year, payment: updated),
        ];
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _patchHistoryCache({
    required String studentId,
    required int year,
    required int month,
    required PaymentRecord record,
  }) {
    final history = _studentHistory[studentId];
    if (history == null) return;
    final idx = history.indexWhere((e) => e.month == month && e.year == year);
    if (idx >= 0) {
      _studentHistory[studentId] = List.of(history)
        ..[idx] = PaymentMonthEntry(month: month, year: year, payment: record);
    }
  }
}

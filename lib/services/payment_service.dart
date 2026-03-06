import '../models/payment_model.dart';
import 'api_client.dart';

class PaymentService {
  final _api = ApiClient.instance;

  // ── Master ──────────────────────────────────────────────────────────────

  Future<List<StudentPaymentOverview>> getMasterMonthOverview({
    required int year,
    required int month,
  }) async {
    final data = await _api.get('/payments/master/overview', query: {
      'year': '$year',
      'month': '$month',
    }) as List<dynamic>;
    return data
        .map((e) => StudentPaymentOverview.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PaymentMonthEntry>> getStudentYearHistory({
    required String studentId,
    required int year,
  }) async {
    final data = await _api.get(
      '/payments/master/student/$studentId',
      query: {'year': '$year'},
    ) as List<dynamic>;
    return data
        .map((e) => PaymentMonthEntry.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<PaymentRecord> togglePayment({
    required String studentId,
    required int year,
    required int month,
  }) async {
    final data = await _api.patch('/payments/toggle', body: {
      'student_id': studentId,
      'year': year,
      'month': month,
    }) as Map<String, dynamic>;
    return PaymentRecord.fromMap(data);
  }

  Future<PaymentRecord> masterSaveReceipt({
    required String studentId,
    required int year,
    required int month,
    required String receiptUrl,
  }) async {
    final data = await _api.patch('/payments/receipt', body: {
      'student_id': studentId,
      'year': year,
      'month': month,
      'receipt_url': receiptUrl,
    }) as Map<String, dynamic>;
    return PaymentRecord.fromMap(data);
  }

  // ── Student ─────────────────────────────────────────────────────────────

  Future<List<PaymentMonthEntry>> getMyPayments({required int year}) async {
    final data = await _api.get('/payments/me', query: {'year': '$year'})
        as List<dynamic>;
    return data
        .map((e) => PaymentMonthEntry.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<PaymentRecord> saveMyReceipt({
    required int year,
    required int month,
    required String receiptUrl,
  }) async {
    final data = await _api.patch('/payments/my-receipt', body: {
      'year': year,
      'month': month,
      'receipt_url': receiptUrl,
    }) as Map<String, dynamic>;
    return PaymentRecord.fromMap(data);
  }
}

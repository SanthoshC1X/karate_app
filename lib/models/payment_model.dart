class PaymentMonthEntry {
  final int month;
  final int year;
  final PaymentRecord? payment;

  const PaymentMonthEntry({
    required this.month,
    required this.year,
    this.payment,
  });

  factory PaymentMonthEntry.fromMap(Map<String, dynamic> map) {
    return PaymentMonthEntry(
      month: map['month'] as int,
      year: map['year'] as int,
      payment: map['payment'] != null
          ? PaymentRecord.fromMap(map['payment'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PaymentRecord {
  final String id;
  final bool isPaid;
  final DateTime? paidAt;
  final String? receiptUrl;
  final String? notes;
  final DateTime? updatedAt;

  const PaymentRecord({
    required this.id,
    required this.isPaid,
    this.paidAt,
    this.receiptUrl,
    this.notes,
    this.updatedAt,
  });

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      id: map['id'] as String,
      isPaid: map['is_paid'] as bool? ?? false,
      paidAt: map['paid_at'] != null ? DateTime.parse(map['paid_at'] as String) : null,
      receiptUrl: map['receipt_url'] as String?,
      notes: map['notes'] as String?,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }
}

/// Used by master's month-overview endpoint — one entry per student.
class StudentPaymentOverview {
  final String studentId;
  final String studentName;
  final String beltLevel;
  final String? profilePictureUrl;
  final PaymentRecord? payment;

  const StudentPaymentOverview({
    required this.studentId,
    required this.studentName,
    required this.beltLevel,
    this.profilePictureUrl,
    this.payment,
  });

  factory StudentPaymentOverview.fromMap(Map<String, dynamic> map) {
    final student = map['student'] as Map<String, dynamic>;
    return StudentPaymentOverview(
      studentId: student['id'] as String,
      studentName: student['name'] as String,
      beltLevel: student['belt_level'] as String? ?? 'White',
      profilePictureUrl: student['profile_picture_url'] as String?,
      payment: map['payment'] != null
          ? PaymentRecord.fromMap(map['payment'] as Map<String, dynamic>)
          : null,
    );
  }
}

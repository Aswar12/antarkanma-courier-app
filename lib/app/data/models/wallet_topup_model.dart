class WalletTopup {
  final int id;
  final int? courierId;
  final double amount;
  final int uniqueCode;
  final double transferAmount;
  final String status; // PENDING, VERIFIED, APPROVED, REJECTED
  final String? paymentProofUrl;
  final String? adminNote;
  final String? verifiedByName;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  WalletTopup({
    required this.id,
    this.courierId,
    required this.amount,
    required this.uniqueCode,
    required this.transferAmount,
    required this.status,
    this.paymentProofUrl,
    this.adminNote,
    this.verifiedByName,
    required this.createdAt,
    this.verifiedAt,
  });

  factory WalletTopup.fromJson(Map<String, dynamic> json) {
    return WalletTopup(
      id: int.tryParse(json['id'].toString()) ?? 0,
      courierId: json['courier_id'] != null
          ? int.tryParse(json['courier_id'].toString())
          : null,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      uniqueCode: int.tryParse(json['unique_code'].toString()) ?? 0,
      transferAmount:
          double.tryParse(json['transfer_amount'].toString()) ?? 0.0,
      status: json['status'] ?? 'PENDING',
      paymentProofUrl: json['payment_proof_url'],
      adminNote: json['admin_note'],
      verifiedByName: json['verified_by_name'],
      createdAt: DateTime.parse(json['created_at']),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courier_id': courierId,
      'amount': amount,
      'unique_code': uniqueCode,
      'transfer_amount': transferAmount,
      'status': status,
      'payment_proof_url': paymentProofUrl,
      'admin_note': adminNote,
      'verified_by_name': verifiedByName,
      'created_at': createdAt.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'PENDING';
  bool get isVerified => status == 'VERIFIED';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';

  String get statusLabel {
    switch (status) {
      case 'PENDING':
        return 'Menunggu Verifikasi';
      case 'VERIFIED':
        return 'Terverifikasi';
      case 'APPROVED':
        return 'Disetujui';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status;
    }
  }
}

class Payment {
  final String apartmentId;
  final String userId;
  final String status;

  Payment({
    required this.apartmentId,
    required this.userId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      "apartmentId": apartmentId,
      "userId": userId,
      "status": status,
    };
  }
}

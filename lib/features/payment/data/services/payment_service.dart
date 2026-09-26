import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment_model.dart';


class PaymentDao {
  Future<void> updatePayment(Payment payment) {
    return FirebaseFirestore.instance
        .collection("payments")
        .doc("${payment.apartmentId}-${payment.userId}")
        .set({
      ...payment.toMap(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDao {
  // Veritabanı örneğine _db ismini verdik
  final _db = FirebaseFirestore.instance;

  /// Kullanıcı ekle
  Future<void> addUser({
    required String apartmentId,
    required int flatNo,
    required String role,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // HATA BURADAYDI: _firestore yerine yukarıdaki _db ismini kullanıyoruz.
    await _db
        .collection('apartments')
        .doc(apartmentId)
        .collection('users')
        .doc(user.uid) // Kullanıcı ID'si dosya adı oldu (Doğru yöntem)
        .set({
      'flatNo': flatNo,
      'role': role,
      'uid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Kullanıcıları getir
  Stream<QuerySnapshot> getUsers(String apartmentId) {
    return _db
        .collection("apartments")
        .doc(apartmentId)
        .collection("users")
        .orderBy("flatNo")
        .snapshots();
  }

  /// 🔥 DAİRE DOLU MU KONTROLÜ
  Future<bool> isFlatOccupied({
    required String apartmentId,
    required int flatNo,
  }) async {
    final snap = await _db
        .collection("apartments")
        .doc(apartmentId)
        .collection("users")
        .where("flatNo", isEqualTo: flatNo)
        .get();

    return snap.docs.isNotEmpty;
  }

  ///Rol güncelleme (admin ↔ resident)
  Future<void> updateUserRole({
    required String apartmentId,
    required String userId,
    required String role,
  }) {
    return _db
        .collection("apartments")
        .doc(apartmentId)
        .collection("users")
        .doc(userId)
        .update({"role": role});
  }

  ///  Admin var mı kontrolü
  Future<bool> adminExists(String apartmentId) async {
    final snap = await _db
        .collection("apartments")
        .doc(apartmentId)
        .collection("users")
        .where("role", isEqualTo: "admin")
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  ///  Global Kullanıcı Profiline Bina Ekleme
  Future<void> addApartmentToGlobalUser(String apartmentId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Burada da _db kullanabiliriz veya direkt instance çağırabiliriz (ikisi de çalışır)
    await _db.collection('users').doc(user.uid).update({
      'joinedApartments': FieldValue.arrayUnion([apartmentId])
    });
  }

  ///  Tek bir kullanıcının bilgilerini getir (Ödeme sayfası için lazım)
  Future<DocumentSnapshot> getUser(String apartmentId, String userId) {
    return _db
        .collection("apartments")
        .doc(apartmentId)
        .collection("users")
        .doc(userId)
        .get();
  }
  // user_dao.dart içine:
  Future<void> deleteUser(String apartmentId, String userId) async {
    await _db
        .collection('apartments')
        .doc(apartmentId)
        .collection('users')
        .doc(userId)
        .delete();
  }
}
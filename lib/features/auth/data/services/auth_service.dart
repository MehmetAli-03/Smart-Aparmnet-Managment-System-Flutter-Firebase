import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcıyı ver
  User? get currentUser => _auth.currentUser;

  // Giriş Yap
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print("Giriş Hatası: $e");
      return null;
    }
  }

  // Kayıt Ol (En Kritik Kısım Burası)
  Future<User?> register(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Firestore'da global kullanıcı profili oluşturuyoruz.
        // joinedApartments listesi BOŞ olarak başlıyor.
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'uid': user.uid,
          'joinedApartments': [], // <-- Bu liste sayesinde hangi binalarda olduğunu bileceğiz
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      print("Kayıt Hatası: $e");
      return null;
    }
  }

  // Çıkış Yap
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
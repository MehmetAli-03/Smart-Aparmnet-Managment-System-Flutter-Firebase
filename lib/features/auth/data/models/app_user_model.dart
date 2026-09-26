class AppUser {
  final String uid;
  final String name;
  final String email;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "createdAt": DateTime.now(),
    };
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map["name"],
      email: map["email"],
    );
  }
}

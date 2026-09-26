class AppUser {
  final int flatNo;
  final String role;

  AppUser({
    required this.flatNo,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      flatNo: data['flatNo'],
      role: data['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "flatNo": flatNo,
      "role": role,
    };
  }
}

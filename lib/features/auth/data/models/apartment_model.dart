class Apartment {
  final String id;
  final String name;
  final int totalFlat;
  final String iban;
  final String code;

  Apartment({
    required this.id,
    required this.name,
    required this.totalFlat,
    required this.iban,
    required this.code,
  });

  factory Apartment.fromMap(String id, Map<String, dynamic> data) {
    return Apartment(
      id: id,
      name: data['name'],
      totalFlat: data['totalFlat'],
      iban: data['iban'],
      code: data['code'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "totalFlat": totalFlat,
      "iban": iban,
      "code": code,
    };
  }
}

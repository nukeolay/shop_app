class User {
  String userId;
  String email;
  String name;
  DateTime? birthDate;
  String? phone;

  User({
    required this.userId,
    required this.email,
    required this.name,
    this.birthDate,
    this.phone,
  });
}

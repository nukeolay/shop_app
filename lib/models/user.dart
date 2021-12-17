class User {
  String userId;
  String email;
  String? name;
  DateTime? birthDate;
  String? phone;
  bool isAdmin;

  User({
    required this.userId,
    required this.email,
    this.name,
    this.birthDate,
    this.phone,
    required this.isAdmin,
  });
}

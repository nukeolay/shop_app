class User {
  String? userId;
  String? email;
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

  void deleteUserData() {
    userId = null;
    email = null;
    name = null;
    birthDate = null;
    phone = null;
    isAdmin = false;
  }
}

class UserFields {
  static const String id = '\$id';
  static const String name = 'name';
  static const String email = 'email';
  static const String registrationDate = 'registration';
  static const String isAdmin = 'isAdmin';

  //static const String roles = 'roles';
}

class User {
  String id;
  bool isAdmin;
  String name;
  String email;
  DateTime? birthDate;
  String? phone;

  User({
    required this.id,
    required this.isAdmin,
    required this.email,
    required this.name,
    this.birthDate,
    this.phone,
  });
}

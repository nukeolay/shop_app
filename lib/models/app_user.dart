class AppUserFields {
  static const String id = '\$id';
  static const String name = 'name';
  static const String email = 'email';
  static const String registrationDate = 'registration';
  //static const String roles = 'roles';
}

class AppUser {
  String id;
  String email;
  int registration;
  String name;
  //List<String> roles;

  AppUser({
    required this.id,
    required this.email,
    required this.registration,
    required this.name,
    //required this.roles,
  });

  AppUser.fromJson(Map<String, dynamic> json)
      : id = json[AppUserFields.id],
        email = json[AppUserFields.email],
        registration = json[AppUserFields.registrationDate],
        name = json[AppUserFields.name]
        //roles = json[AppUserFields.roles].cast<String>()
        ;

  Map<String, dynamic> toJson() {
    return {
      AppUserFields.id: id,
      AppUserFields.email: email,
      AppUserFields.registrationDate: registration,
      //AppUserFields.roles: roles,
    };
  }
}

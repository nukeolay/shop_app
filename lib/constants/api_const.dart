class Api {
  static const String base = 'https://identitytoolkit.googleapis.com/v1/';
  static const String apiKey = 'AIzaSyB8KVWC48jKOJmcyiJclJ294njNYG8NS8M';
  static const String login =
      '$base/accounts:signInWithPassword';
  static const String register =
      '$base/accounts:signUp';
  static const String refreshToken =
      'https://securetoken.googleapis.com/v1/token';
}

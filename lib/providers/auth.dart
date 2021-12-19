import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_const.dart';
import '../models/user.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  final _user = User(userId: '', email: '', isAdmin: false);
  late String? _token;
  late String? _refreshToken;
  late DateTime? _expireDate;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    try {
      if (_expireDate != null &&
          _expireDate!.isAfter(DateTime.now()) &&
          _token != null) {
        return _token;
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  String? get userId => _user.userId;

  String? get email => _user.email;

  Future<void> _refreshAuth() async {
    final url = Uri.parse('${Api.refreshToken}?key=${Api.apiKey}');
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'grant_type': 'refresh_token',
            'refresh_token': _refreshToken,
          },
        ),
      );
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['id_token'];
      _expireDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expires_in']),
        ),
      );
      _refreshToken = responseData['refresh_token'];
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode(
        {
          'token': _token,
          'userId': _user.userId,
          'email': _user.email,
          'refreshToken': _refreshToken,
          'expireDate': _expireDate!.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> setUserData(User user) async {}

  Future<void> _authenticate(
    String email,
    String password,
    String urlSegment,
  ) async {
    final url = Uri.parse('$urlSegment?key=${Api.apiKey}');

// если регистрация, то создать в ../users/$userId/разные поля

    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _user.userId = responseData['localId'];
      _user.email = responseData['email'];
      _refreshToken = responseData['refreshToken'];
      _expireDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode(
        {
          'token': _token,
          'userId': _user.userId,
          'email': email,
          'refreshToken': _refreshToken,
          'expireDate': _expireDate!.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, Api.register);
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, Api.login);
  }

  Future<bool> tryAutologin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    } else {
      final extractedUserData =
          jsonDecode(prefs.getString('userData')!) as Map<String, dynamic>;
      final expireDate = DateTime.parse(extractedUserData['expireDate']);
      if (expireDate.isBefore(DateTime.now())) {
        return false;
      } else {
        _token = extractedUserData['token'];
        _user.userId = extractedUserData['userId'];
        _user.email = extractedUserData['email'];
        _refreshToken = extractedUserData['refreshToken'];
        _expireDate = expireDate;
        _autoLogout();
        notifyListeners();
        return true;
      }
    }
  }

  Future<void> logout() async {
    _token = null;
    _user.deleteUserData();
    _refreshToken = null;
    _expireDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expireDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), _refreshAuth);
  }
}

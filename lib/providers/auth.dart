import 'dart:async';

import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/server_constants.dart';
import '../models/user.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  late appwrite.Client _client;
  late appwrite.Account _account;
  late User _user;
  appwrite_models.Session? _session;

  Auth() {
    _init();
  }

  _init() async {
    print('1 Auth() init called');
    _client = appwrite.Client();
    _account = appwrite.Account(_client);
    _client
        .setEndpoint(ServerConstants.endpoint)
        .setProject(ServerConstants.projectId);
    _user = User(id: '', isAdmin: false, email: '', name: '');
    await tryAutologin();
  }

  bool get isLogged {
    return _session != null;
  }

  String? get token {
    return _session.toString();
    // try {
    //   if (_expireDate != null &&
    //       _expireDate!.isAfter(DateTime.now()) &&
    //       _token != null) {
    //     return _token;
    //   }
    //   return null;
    // } catch (error) {
    //   return null;
    // }
  }

  String get userId => _user.id;

  String get email => _user.email;

  String get name => _user.name;

  bool get isAdmin => _user.isAdmin;

  Future<bool> tryAutologin() async {
    print('---"Auth.tryAutologin" called');
    try {
      appwrite_models.User appwriteUser = await _account.get();
      _session = await _account.getSession(sessionId: 'current');
      appwrite_models.Preferences userPrefs = await _account.getPrefs();

      _user.id = appwriteUser.$id;
      _user.email = appwriteUser.email;
      _user.name = appwriteUser.name;
      _user.isAdmin = userPrefs.data[UserFields.isAdmin];

      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      appwrite_models.User appwriteUser = await _account.create(
        email: email,
        password: password,
        name: name,
      );
      _session = await _account.createSession(email: email, password: password);
      await _account.updatePrefs(prefs: {UserFields.isAdmin: false});
      _user.id = appwriteUser.$id;
      _user.email = appwriteUser.email;
      _user.name = appwriteUser.name;
      _user.isAdmin = false;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _session = await _account.createSession(
          email: email,
          password: password); //тут createSession или getSession('current')?
      appwrite_models.User appwriteUser = await _account.get();
      appwrite_models.Preferences userPrefs = await _account.getPrefs();

      _user.id = appwriteUser.$id;
      _user.email = appwriteUser.email;
      _user.name = appwriteUser.name;
      _user.isAdmin = userPrefs.data[UserFields.isAdmin];
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
    _session = null;
    notifyListeners();
  }
}

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

  _init() {
    _client = appwrite.Client();
    _account = appwrite.Account(_client);
    _client
        .setEndpoint(ServerConstants.endpoint)
        .setProject(ServerConstants.projectId);
    _user = User(userId: '', email: '', name: '');
    tryAutologin();
  }

  bool get isAuth {
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

  String get userId => _user.userId;

  String get email => _user.email;

  String get name => _user.name;

  Future<bool> tryAutologin() async {
    try {
      appwrite_models.User appwriteUser = await _account.get();
      _session = await _account.getSession(sessionId: 'current');
      
      _user.userId = appwriteUser.$id;
      _user.email = appwriteUser.email;
      _user.name = appwriteUser.name;
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
      _user.userId = appwriteUser.$id;
      _user.email = appwriteUser.email;
      _user.name = appwriteUser.name;
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
      _user.userId = appwriteUser.$id;
      _user.email = appwriteUser.email;
      _user.name = appwriteUser.name;
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

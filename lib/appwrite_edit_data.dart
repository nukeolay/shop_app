import 'dart:async';

import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter/material.dart';
import '../core/constants/server_constants.dart';
import '../models/user.dart';

class AppWriteEditData extends StatelessWidget {
  const AppWriteEditData({Key? key}) : super(key: key);

  Future<appwrite_models.User> updateData() async {
    final appwrite.Client _client = appwrite.Client();
    final appwrite.Account _account = appwrite.Account(_client);
    _client
        .setEndpoint(ServerConstants.endpoint)
        .setProject(ServerConstants.projectId);
    await _account.get();
    await _account.getSession(sessionId: 'current');
    return _account.updatePrefs(prefs: {UserFields.isAdmin: true});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FutureBuilder(
            future: updateData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                appwrite_models.User _user =
                    snapshot.data as appwrite_models.User;
                return Text(
                    'id: ${_user.$id}, name: ${_user.name}, prefs: ${_user.prefs.data}');
              } else {
                return const Icon(Icons.error);
              }
            },
          ),
        ),
      ),
    );
  }
}

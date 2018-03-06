
library singleton;

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String email = '';
  String password = '';

  static final UserData _singleton = new UserData._internal();
  UserData._internal();
  static UserData get instance => _singleton;

  load () async {
    final SharedPreferences prefs = await _prefs;

    if (prefs.getString('email') != null &&
        prefs.getString('password') != null) {
      this.email = prefs.getString('email');
      this.password = prefs.getString('password');
    }

    await new Future.delayed(const Duration(seconds: 1));
    return true;

  }

  Future<bool> save () async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('email', this.email);
    prefs.setString('password', this.password);
    await new Future.delayed(const Duration(seconds: 1));
    return true;
  }

  reset () async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove('email');
    prefs.remove('password');
    this.email = '';
    this.password = '';
    await new Future.delayed(const Duration(seconds: 2));
    return true;
  }
}

var user = new UserData._internal();

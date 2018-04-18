
library singleton;

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String email = '';
  String password = '';
  String ftpHost = '';
  String ftpUsername = '';
  String ftpPassword = '';
  String ftpValid = 'false';

  static final UserData _singleton = new UserData._internal();
  UserData._internal();
  static UserData get instance => _singleton;

  load () async {
    final SharedPreferences prefs = await _prefs;
    this.email = prefs.getString('email');
    this.password = prefs.getString('password');
    this.ftpHost = prefs.getString('ftpHost');
    this.ftpUsername = prefs.getString('ftpUsername');
    this.ftpPassword = prefs.getString('ftpPassword');
    this.ftpValid = prefs.getString('ftpValid');
    return true;
  }

  Future<bool> save () async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('email', this.email);
    prefs.setString('password', this.password);
    prefs.setString('ftpHost', this.ftpHost);
    prefs.setString('ftpUsername', this.ftpUsername);
    prefs.setString('ftpValid', this.ftpValid);
    return true;
  }

  reset () async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove('email');
    prefs.remove('password');
    this.email = '';
    this.password = '';
    return true;
  }
}

var user = new UserData._internal();

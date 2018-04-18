
library singleton;

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

  Future<bool> load () async {
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
    prefs.setString('ftpPassword', this.ftpPassword);
    prefs.setString('ftpValid', this.ftpValid);
    return true;
  }

  Future<bool> reset () async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove('email');
    prefs.remove('password');
    this.email = '';
    this.password = '';
    return true;
  }

  Future verify (Function result) async {
    final Uri uri = new Uri.http("192.168.1.107:8000", "/verify");
    // final Uri uri = new Uri.http("ec2-52-90-192-206.compute-1.amazonaws.com", "/verify");
    final request = new http.MultipartRequest('POST', uri);
    request.fields['ftp-host'] = user.ftpHost;
    request.fields['ftp-user'] = user.ftpUsername;
    request.fields['ftp-password'] = user.ftpPassword;

    request.send().then((response) {
      response.stream.transform(UTF8.decoder).listen((data) {
        result(json.decode(data));
      });
    });

  }
}

var user = new UserData._internal();

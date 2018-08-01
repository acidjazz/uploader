import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import '../UserData.dart';


class Login extends StatefulWidget {
  @override
  LoginState createState() => new LoginState();
}

class LoginState extends State<Login> {

  var _loadedInitials = false;
  var _version = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value),
        duration: const Duration(seconds: 3),
    ));
  }

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Future _enter() async {
    await user.load();
    if (user.ftpValid == 'true') {
      Navigator.of(context).pushReplacementNamed('/inventories');
    } else {
      Navigator.of(context).pushReplacementNamed('/settings');
    }
  }

  Image _loginLogo() {
    if (MediaQuery.of(context).viewInsets.bottom == 0) {
      return new Image.asset('images/icon-small.png', width: 100.0);
    } else {
      return new Image.asset('images/icon-small.png', width: 0.0);
    }
  }

  Positioned _versionWidget() {
    return Positioned( // red box
      child: Text(
        "v$_version",
      ),
      bottom: 24.0,
      right: 24.0,
    );
  }

  void init() async {
    await user.load();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _loadedInitials = true;
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (!_loadedInitials) init();

    if (_loadedInitials) {
      return new Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(title: new Text('Welcome to Maxanet')),
          body: new Stack(
            children: <Widget> [
              new Container(
                padding: new EdgeInsets.symmetric(horizontal: 30.0),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _loginLogo(),
                    new Text(
                      'Maxanet Uploader',
                      style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                    ),
                    new Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 30.0
                      ),
                      child: new Text(
                        'Upload auction photos & item information quickly & easily from your mobile device or tablet',
                        style: new TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.center,
                      )
                    ),
                    new Container(
                      padding: const EdgeInsets.all(20.0),
                      alignment: Alignment.center,
                      child: new RaisedButton(
                        child: const Text('GET STARTED'),
                        onPressed: _enter,
                      ),
                    ),
                  ],
                ),
            ),
              _versionWidget(),
            ],
          ),
      );
    } else {
      return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar( title: new Text('Welcome to Maxanet')),
        body: new Center( key: _formKey, child: new CircularProgressIndicator()),
      );
    }
  }
}

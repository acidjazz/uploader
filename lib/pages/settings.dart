import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maxanet_uploader/HomeDrawer.dart';
import 'package:maxanet_uploader/UserData.dart';

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => new SettingsState();
}

class SettingsState extends State<Settings> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  bool _verifying = false;

  Future _handleSave () async {

    setState(() => _verifying = true);
    _snackBar('Verifying FTP Credentials');

  }

  void _snackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(title: new Text('Settings')),
      drawer: new HomeDrawer('/settings'),
      body: new Form(
        key: _formKey,
        child: new Container(
          padding: new EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
          child: new Column(
            children: <Widget>[
              new TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.computer),
                  labelText: 'FTP Host',
                ),
                initialValue: user.ftpHost,
                keyboardType: TextInputType.text,
                onSaved: (String value) { user.ftpHost = value; }
                ),
              new TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.account_box),
                  labelText: 'FTP Username',
                ),
                initialValue: user.ftpUsername,
                keyboardType: TextInputType.text,
                onSaved: (String value) { user.ftpUsername = value; }
              ),
              new TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.lock),
                  labelText: 'FTP Password',
                ),
                initialValue: user.ftpPassword ,
                keyboardType: TextInputType.text,
                onSaved: (String value) { user.ftpPassword = value; }
              ),
              new Container(
                padding: const EdgeInsets.all(20.0),
                alignment: Alignment.center,
                child: _verifying ?
                new CircularProgressIndicator() :
                new RaisedButton(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
                  child: const Text("SAVE"),
                  onPressed: _handleSave,
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }

}
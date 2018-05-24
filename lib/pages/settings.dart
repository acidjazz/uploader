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

  var _loaded = false;
  bool _processing = false;

  Future<bool> _handleSave () async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _snackBar('Please fill in all settings');
      return false;
    }
    user.ftpValid = 'false';
    setState(() => _processing = true);
    _snackBar('Saving and Verifying.. ', 1);
    form.save();
    await user.save();
    await user.verify((data) async {

      if (data['valid'] == false) {
        _snackBar('FTP Credentials are invalid');
        setState(() => _processing = false);
      } else {
        user.ftpValid = 'true';
        await user.save();
        setState(() => _processing = false);

        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: const Text('FTP Crendentails are valid!'),
          duration: new Duration(seconds: 10),
          action: new SnackBarAction(
            label: 'Go to Inventories',
            onPressed: () => Navigator.of(context).pushReplacementNamed('/inventories')
          ),
        ));
      }

    });

    return true;
  }

  String _validateField(String value) {
    if (value.isEmpty) {
      return 'Please specify this field';
    }
    return null;
  }

  void init() async {
    await user.load();
    setState(() => _loaded = true);
    print('init()');
    print(user.ftpHost);
  }

  void _snackBar(String value, [int seconds=3]) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      duration: new Duration(seconds: seconds),
    ));
  }

  @override
  Widget build(BuildContext context) {

    if (!_loaded) init();
    if (_loaded) {
      return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('Settings'),
          actions: <Widget>[
            new FlatButton(
            onPressed: _handleSave,
              child: new Text('SAVE', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        drawer: new HomeDrawer('/settings'),
        body: new Form(
          key: _formKey,
          child: new Container(
            padding: new EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
            child: SingleChildScrollView(
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.computer),
                      labelText: 'FTP Host',
                    ),
                    validator: _validateField,
                    initialValue: user.ftpHost,
                    keyboardType: TextInputType.url,
                    onSaved: (String value) {
                      user.ftpHost = value;
                    },
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.account_box),
                      labelText: 'FTP Username',
                    ),
                    validator: _validateField,
                    initialValue: user.ftpUsername,
                    keyboardType: TextInputType.url,
                    onSaved: (String value) {
                      user.ftpUsername = value;
                    },
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.lock),
                      labelText: 'FTP Password',
                    ),
                    validator: _validateField,
                    initialValue: user.ftpPassword,
                    keyboardType: TextInputType.url,
                    onSaved: (String value) {
                      user.ftpPassword = value;
                    },
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.link),
                      labelText: 'Publish URL',
                    ),
                    validator: _validateField,
                    initialValue: user.publishURL,
                    keyboardType: TextInputType.url,
                    onSaved: (String value) {
                      user.publishURL = value;
                    },
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.link),
                      labelText: 'Admin URL',
                    ),
                    // validator: _validateField,
                    initialValue: user.adminURL,
                    keyboardType: TextInputType.url,
                    onSaved: (String value) {
                      user.adminURL = value;
                    },
                  ),
                ]
              ),
            ),
          ),
        ),
      );
    } else {
      return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar( title: new Text('Settings')),
        body: new Center( key: _formKey, child: new CircularProgressIndicator()),
      );
    }
  }

}

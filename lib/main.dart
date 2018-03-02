import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      home: new LoginScreen(),
      theme: new ThemeData(
        primaryColor: Colors.blue,
      )
    );

  }
}

class LoginScreen extends StatefulWidget {
  @override
  createState() => new LoginState();
}

class LoginState extends State {
  @override
  Widget build(BuildContext context) {
    final _title = new TextStyle(
      fontSize: 30.0,
    );
    return new Scaffold(
      body: new Center(
        child: new Text('Maxanet Uploader', style: _title),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'login.dart';
import 'home.dart';

void main() => runApp(new Uploader());

class Uploader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Maxanet Uploader',
      home: new Center(child: new Login()),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new Home(),
        '/login': (BuildContext context) => new Login(),
      },
    );
  }
}


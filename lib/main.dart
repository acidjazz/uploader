import 'package:flutter/material.dart';
import 'pages/inventory.dart';
import 'pages/login.dart';
import 'pages/home.dart';

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
        '/inventory': (BuildContext context) => new Inventory(),
      },
    );
  }
}


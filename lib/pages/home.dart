import 'package:flutter/material.dart';
import '../HomeDrawer.dart';


class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Home> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(title: new Text('Maxanet Uploader')),
      body: new Center(child: new Icon(Icons.home, size: 60.0, color: Colors.blue)),
      drawer: new HomeDrawer('/home'),
    );
  }

}
import 'package:flutter/material.dart';

class Inventory extends StatefulWidget {
  @override
  InventoryState createState() => new InventoryState();
}

class InventoryState extends State<Inventory> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: new Center(child: new Text('Inventory Screen')),
    );
  }

}

import 'package:flutter/material.dart';
import 'HomeDrawer.dart';

class Inventory extends StatefulWidget {
  @override
  InventoryState createState() => new InventoryState();
}

class InventoryState extends State<Inventory> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Inventory to Upload')),
      body: new Center(child: new Text('You have no inventory yet')),
      drawer: new HomeDrawer('/inventory'),
    );
  }

}

import 'package:flutter/material.dart';
import 'HomeDrawer.dart';
import 'InventoryData.dart';

class Inventory extends StatefulWidget {
  @override
  InventoryState createState() => new InventoryState();
}

class InventoryState extends State<Inventory> {

  _body () {
    if (inventory.Inventory.length < 1) {
      return new Center(child: new Text('You have no inventory yet'));
    } else {
      return new Column();
    }
  }

  _addInventoryRoute () {

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Inventory to Upload')),
      drawer: new HomeDrawer('/inventory'),
      body: _body(),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add',
        child: new Icon(Icons.add),
        onPressed: _addInventoryRoute,
      ),
    );
  }

}

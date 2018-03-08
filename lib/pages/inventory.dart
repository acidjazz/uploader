import 'package:flutter/material.dart';
import '../HomeDrawer.dart';
import '../InventoryData.dart';
import 'inventoryModify.dart';

class Inventory extends StatefulWidget {
  @override
  InventoryState createState() => new InventoryState();
}

class InventoryState extends State<Inventory> {

  var _loadedInv = false;

  loadInventory () async {
    await inventory.load();
    setState(() { _loadedInv = true; });
  }

  body () {
    if (_loadedInv) {
      if (inventory.items.length < 1) {
        return new Center(child: new Text('You have no inventory yet'));
      } else {
        return _inventoryWidget();
      }
    } else {
      return new Center(
        child: new CircularProgressIndicator()
      );
    }
  }

  _inventoryWidget () {
    return new ListView(
      children: inventory.items.map((InventoryItem item) {
        return new ListTile(
          title: new Text(item.name),
          subtitle: new Text(item.description),
          onTap: () { _toInventoryModify(inventory.items.indexOf(item), item); },
        );
      }).toList(),
    );
  }

  _toInventoryModify (int index, InventoryItem item) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => new InventoryModify(index, item)
      )
    );
  }

  _toInventoryCreate () {
    Navigator.of(context).push(
      new MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => new InventoryModify(null, null),
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    if (!_loadedInv) loadInventory();

    return new Scaffold(
      appBar: new AppBar(title: new Text('Inventory to Upload')),
      drawer: new HomeDrawer('/inventory'),
      body: body(),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add',
        child: new Icon(Icons.add),
        onPressed: _toInventoryCreate,
      ),
    );
  }

}

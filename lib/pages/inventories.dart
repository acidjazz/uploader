import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxanet_uploader/HomeDrawer.dart';
import 'package:maxanet_uploader/InventoriesData.dart';


class Inventories extends StatefulWidget {
  @override
  InventoriesState createState() => new InventoriesState();
}

class InventoriesState extends State<Inventories> {

  var _loaded = false;

  var textName;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  loadInventories () async {
    await inventories.load();
    setState(() { _loaded = true; });
  }

  _addHandler () async {
    final FormState form = _formKey.currentState;
    form.save();

    if (form.validate()) {
      inventories.items.add(new InventoriesItem(textName));
      await inventories.save();
      Navigator.pop(context);
      _toInventory(textName);
    }
  }

  String _validateName (String value) {
    if (value.isEmpty) {
      return 'Please specify a name';
    }
    if (inventories.items.map((item) => item.name).toList().indexOf(textName) != -1) {
      return 'Inventory name already exists';
    }
    return null;
  }

  _addDialog () {
    // modal that prompts them the name/label
    showDialog(
      context: context,
      child: new _SystemPadding(child: new AlertDialog(
        title: new Text("Inventory Name"),
        content: new Form(
          key: _formKey,
          child: new TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.bookmark),
              // hintText: 'Your new Inventory name',
              // labelText: 'Inventory Name',
            ),
            onSaved: (String value) { textName = value; },
            validator: _validateName,
            autofocus: true,

          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text("CANCEL"),
            onPressed: () => Navigator.pop(context),
          ),
          new FlatButton(
            child: new Text("ADD"),
            onPressed: _addHandler,
          ),
        ]
      )),
    );
  }

  void _remove (name) async {

    showDialog(
      context: context,
      child: new AlertDialog(
        content: new Text('Are you sure you want to delete $name?'),
      actions: <Widget>[
        new FlatButton( child: new Text("CANCEL"), onPressed: () => Navigator.pop(context)),
        new FlatButton( child: new Text("DELETE"), onPressed: () async {
          Navigator.pop(context);
          await inventories.remove(name);
          setState(() {
            _loaded = false;
          });
        }),
        ]
      ),
    );

  }

  _body () {
    if (_loaded) {
      if (inventories.items.length < 1) {
        return new Center(
          child: new Text('You have no inventories yet', style: new TextStyle(fontSize: 20.0))
        );
      } else {
        return _inventoriesWidget();
      }
    } else {
      return new Center(
        child: new CircularProgressIndicator()
      );
    }
  }

  _inventoriesWidget() {
    return new ListView(
      children: inventories.items.map((item) {
        return new ListTile(
          leading: new Icon(Icons.assignment),
          trailing: new IconButton(icon: new Icon(Icons.delete), onPressed: () { _remove(item.name); }),
          /*
          trailing: new PopupMenuButton(
            onSelected: (choice) { _remove(item.name); },
            itemBuilder: (BuildContext context) {
              return [
                new PopupMenuItem(
                  value: 'delete',
                  child: new Text('Delete'),
                )
              ];
            }
          ),
          */
          title: new Text(item.name),
          subtitle: new Text(item.stats()),
          onTap: () { _toInventory(item.name); },
        );
      }).toList(),
    );
  }

  _toInventory(String name) async {
    await Navigator.pushNamed(context, '/inventory/$name');
    _loaded = false;
  }

  _snackBar(message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
    ));
  }


  @override
  Widget build(BuildContext context) {

    if (!_loaded) loadInventories();

    return new Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: true,
      appBar: new AppBar(
        title: new Text('Inventories'),
      ),
      drawer: new HomeDrawer('/inventories'),

      body: _body(),

      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add an Inventory',
        child: new Icon(Icons.add),
        onPressed: _addDialog,
      ),

    );

  }

}

// remove this after beta update, shouldn't be needed anymore
// ref: https://github.com/flutter/flutter/pull/15426
class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
      padding: mediaQuery.viewInsets,
      duration: const Duration(milliseconds: 60),
      child: child);
  }
}
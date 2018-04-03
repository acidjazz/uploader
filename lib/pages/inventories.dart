import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Inventories extends StatefulWidget {
  @override
  InventoriesState createState() => new InventoriesState();
}

class InventoriesState extends State<Inventories> {

  var textName;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _addHandler () {
    print('WE GOT $textName');
    if (textName != null && textName != '') {
      Navigator.pop(context);
      return true;
    }
    _snackBar('Invalid Inventory Name');
    return null;
  }
  _add () {
    // modal that prompts them the name/label

    showDialog(
      context: context,
      child: new _SystemPadding(child: new AlertDialog(
        title: new Text("Label your Inventory"),
        content: new TextField(
          decoration: const InputDecoration(
            icon: const Icon(Icons.bookmark),
            hintText: 'Your new Inventory name',
            labelText: 'Inventory Name',
          ),
          onChanged: (String text) {
            textName = text;
          },
          autofocus: true,

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

  _snackBar(message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: true,
      appBar: new AppBar(
        title: new Text('Inventories'),
      ),

      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add an Inventory',
        child: new Icon(Icons.add),
        onPressed: _add,
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
      duration: const Duration(milliseconds: 300),
      child: child);
  }
}
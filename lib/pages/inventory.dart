import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../HomeDrawer.dart';
import '../InventoryData.dart';
import 'inventoryModify.dart';
import 'package:connectivity/connectivity.dart';

class Inventory extends StatefulWidget {
  final String name;
  Inventory(this.name);
  @override
  InventoryState createState() => new InventoryState();
}

// class InventoryState extends State<Inventory> with WidgetsBindingObserver {
class InventoryState extends State<Inventory> {

  var _loadedInv = false;
  var _loadedSignal = false;
  var _signalSubscription;
  var _connection = Icons.signal_cellular_connected_no_internet_4_bar;
  var _internet = false;

  var workspaceId;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  /*
  @override
  didPopRoute () async => false;
  */

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  loadInventory () async {
    await inventory.load(widget.name);
    setState(() { _loadedInv = true; });
  }

  loadSignal () async {
    var result = await (new Connectivity().checkConnectivity());
    _connection = setConnectivity(result);
    setState(() { _loadedSignal = true; });

    if (_signalSubscription == null) {
      _signalSubscription = new Connectivity().onConnectivityChanged
      .listen((ConnectivityResult result) {
        setState(() { _connection = setConnectivity(result); });
      });
    }

  }

  setConnectivity (ConnectivityResult result) {
    if (result == ConnectivityResult.mobile) {
      _internet = true;
      return Icons.signal_cellular_4_bar;
    } else if (result == ConnectivityResult.wifi) {
      _internet = true;
      return Icons.signal_wifi_4_bar;
    } else {
      _internet = false;
      return Icons.signal_wifi_off;
    }
  }

  _body () {
    if (_loadedInv) {
      if (inventory.items.length < 1) {
        return new Center(
          child: new Text('Click the "+" to add an item to ${widget.name}', style: new TextStyle(fontSize: 20.0),));
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
      children: inventory.items.map((InventoryItem item)
        => _listProgressTile(item)).toList(),
    );
  }

  _listProgressTile(InventoryItem item) {
    double _progress = item.progress;
    return new Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _listTile(item),
        new LinearProgressIndicator(value: _progress),
      ]

    );

  }

  _leading(InventoryItem item) {

    if (item.uploading == 'true') {
      return new CircularProgressIndicator();
    }

    if (item.uploaded == 'true') {
      return new Icon(Icons.check);
    }

    return new Icon(Icons.file_upload);
  }

  _listTile(InventoryItem item) {
    return new ListTile(
      title: new Text(item.name),
      subtitle: new Text(item.description),
      onTap: () { _toInventoryModify(inventory.items.indexOf(item), item); },
      isThreeLine: true,
      leading: _leading(item),
      trailing: new Container(
        height: 80.0,
        width: 80.0,
        child: new Stack(
          alignment: Alignment.center,
          overflow: Overflow.visible,
          children: item.photos.getRange(0, item.photos.length > 2 ? 3 : item.photos.length).toList().reversed.map((photo) {
            return new Positioned(
              right: 20.0*item.photos.indexOf(photo),
              width: 60.0,
              height: 60.0,
              child: new Container(
                child: new Image.file(new File(inventory.path(photo.path)), fit: BoxFit.cover),
                decoration: new BoxDecoration(
                  border: new Border(right: new BorderSide(
                    width: photo == item.photos.first ? 0.0 : 1.0,
                    color: Colors.white)
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  _toInventoryModify (int index, InventoryItem item) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => new InventoryModify(index, item, widget.name)
      )
    );
  }

  _toInventoryCreate () {
    Navigator.of(context).push(
      new MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => new InventoryModify(null, null, widget.name),
      )
    );
  }
  _snackBar(message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
    ));
  }

  _canAction () {

    if (inventory.items == null) {
      return 'Inventory not loaded yet';
    }

    if (inventory.items.length < 1) {
      return 'You have no inventory yet';
    }

    if (_internet == false) {
      return 'Internet is required to upload inventory';
    }

    return null;
  }

  _actionButton () {

    Function action;
    String copy;

    if (inventory.uploaded == 'false') {
      action = _uploadItems;
      copy = 'UPLOAD';
    }

    if (inventory.uploading == 'true') {
      action = _cancelUpload;
      copy = 'CANCEL';
    }

    if (inventory.uploaded == 'true') {
      action = _publishDialog;
      copy = 'PUBLISH';
    }

    return new FlatButton.icon(
      onPressed: action,
      icon: new Icon(
        _connection,
        color: _internet ? Colors.white : Colors.white30),
      label: new Text(copy,
      style: new TextStyle(
        color: _canAction() == null ? Colors.white : Colors.white30
        )
      ),
    );

  }

  _cancelUpload () {
    inventory.cancel = 'true';
  }

  String _validateWorkspaceId (String value) {
    if (value.isEmpty) {
      return 'Please specify a workspace';
    }
    return null;
  }

  _publishDialog () {
    showDialog(
      context: context,
      child: new _SystemPadding(child: new AlertDialog(
        title: new Text("Workspace ID"),
        content: new Form(
          key: _formKey,
          child: new TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.bookmark),
            ),
            onSaved: (String value) { workspaceId = value; },
            validator: _validateWorkspaceId,
            autofocus: true,

          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text("CANCEL"),
            onPressed: () => Navigator.pop(context),
          ),
          new FlatButton(
            child: new Text("PUBLISH"),
            onPressed: _publishItems,
          ),
        ]
      )),
    );
  }

  _publishItems () async {

    final FormState form = _formKey.currentState;
    form.save();

    if (!form.validate()) {
      return false;
    }

    Navigator.pop(context);

    inventory.post(workspaceId);
    setState(() => _snackBar('Inventory successfully published'));

  }
  _uploadItems () async {

    if (_canAction() != null) {
      _snackBar(_canAction());
      return false;
    }

    setState(() {
      inventory.uploading = 'true';
      _snackBar('Starting upload process');
    });

    for (var itemIndex = 0; itemIndex < inventory.items.length; itemIndex++) {

      if (inventory.cancel == 'true') {
        break;
      }

      InventoryItem item = inventory.items[itemIndex];

      setState(() {
        item.uploading = 'true';
        item.progress = 0.0;
      });

      for (var photoIndex = 0; photoIndex < item.photos.length; photoIndex++) {

        if (inventory.cancel == 'true') {
          break;
        }

        InventoryItemPhoto photo = item.photos[photoIndex];
        await photo.upload('${itemIndex+1}-${photoIndex+1}');
        setState(() {
          item.progress = (photoIndex+1)/item.photos.length;
        });
      }

      setState(() {
        item.progress = 1.0;
        item.uploading = 'false';
        item.uploaded = 'true';
        inventory.save(widget.name);
        _snackBar('Images for ${item.name} saved');
      });

    }

    if (inventory.cancel == 'true') {
      inventory.cancel = 'false';
      inventory.uploading = 'false';
      _snackBar('Upload process cancelled');
      return true;
    }

    setState(() {
      inventory.uploading = 'false';
      inventory.uploaded = 'true';
      _snackBar('Upload process complete');
    });

    return true;

  }

  Future<bool> _onWillPop () async => inventory.uploading == 'false';

  @override
  Widget build(BuildContext context) {

    if (!_loadedInv) loadInventory();
    if (!_loadedSignal) loadSignal();

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(widget.name),
          actions: <Widget>[
            new FlatButton(
              onPressed: null,
              child: _actionButton(),
            )
          ],
        ),
        body: _body(),
        floatingActionButton: new FloatingActionButton(
          tooltip: 'Add',
          child: new Icon(Icons.add),
          onPressed: _toInventoryCreate,
        ),
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

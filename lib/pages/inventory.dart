import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maxanet_uploader/InventoriesData.dart';
import 'package:maxanet_uploader/UserData.dart';
import '../InventoryData.dart';
import 'inventoryModify.dart';
import 'package:connectivity/connectivity.dart';

class Inventory extends StatefulWidget {
  final String name;
  Inventory(this.name);

  @override
  InventoryState createState() => new InventoryState();
}

class InventoryState extends State<Inventory> {
  var _loaded = false;
  var _loadedSignal = false;
  var _signalSubscription;
  var _connection = Icons.signal_cellular_connected_no_internet_4_bar;
  var _internet = false;

  int _bottomIndex = 0;

  String workspaceId;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<void> loadInventory() async {
    await inventory.load(widget.name);
    await user.load();
    _bottomBarIndex();
    setState(() {
      _loaded = true;
    });
  }

  void loadSignal() async {
    var result = await (new Connectivity().checkConnectivity());
    _connection = setConnectivity(result);
    setState(() {
      _loadedSignal = true;
    });

    if (_signalSubscription == null) {
      _signalSubscription = new Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) {
        setState(() {
          _connection = setConnectivity(result);
        });
      });
    }
  }

  IconData setConnectivity(ConnectivityResult result) {
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

  Widget _body() {
    if (_loaded) {
      if (inventory.items.length < 1) {
        return new Center(
            child: new Text(
          'Click the "+" to add an item to ${widget.name}',
          style: new TextStyle(fontSize: 20.0),
        ));
      } else {
        return _inventoryWidget();
      }
    } else {
      return new Center(child: new CircularProgressIndicator());
    }
  }

  Widget _inventoryWidget() {
    return new ListView(
      children: inventory.items.map((item) => _listProgressTile(item)).toList(),
    );
  }

  Widget _listProgressTile(item) {
    double _progress = item.progress;
    return new Stack(alignment: Alignment.bottomCenter, children: <Widget>[
      _listTile(item),
      new LinearProgressIndicator(value: _progress),
    ]);
  }

  Widget _leading(item) {
    if (item.uploading == 'true') {
      return new CircularProgressIndicator();
    }

    if (item.uploaded == 'true') {
      return new Icon(Icons.check);
    }

    return new Icon(Icons.file_upload);
  }

  Widget _listTile(InventoryItem item) {
    return new ListTile(
      title: new Text(item.name),
      subtitle: new Text(item.description),
      onTap: () {
        _toInventoryModify(inventory.items.indexOf(item), item);
      },
      isThreeLine: true,
      leading: _leading(item),
      trailing: new Container(
        height: 80.0,
        width: 80.0,
        child: new Stack(
          alignment: Alignment.center,
          overflow: Overflow.visible,
          children: item.photos
              .getRange(0, item.photos.length > 2 ? 3 : item.photos.length)
              .toList()
              .reversed
              .map(
                (photo) => new Positioned(
                      right: 20.0 * item.photos.indexOf(photo),
                      width: 60.0,
                      height: 60.0,
                      child: new Container(
                        child: new Image.file(
                            new File(inventory.path(photo.path)),
                            fit: BoxFit.cover),
                        decoration: new BoxDecoration(
                          border: new Border(
                              right: new BorderSide(
                                  width: photo == item.photos.first ? 0.0 : 1.0,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<Null> _toInventoryModify(int index, InventoryItem item) async {
    await Navigator.of(context).push(new MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => new InventoryModify(index, item, widget.name)));
    _loaded = false;
  }

  Future<Null> _toInventoryCreate() async {
    await Navigator.of(context).push(new MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => new InventoryModify(null, null, widget.name),
        ));
    _loaded = false;
  }

  void _snackBar(message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
    ));
  }

  String _canAction() {
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

  void _cancelUpload() {
    inventory.cancel = 'true';
  }

  String _validateWorkspaceId(String value) {
    if (value.isEmpty) {
      return 'Please specify a workspace';
    }
    return null;
  }

  void _publishDialog() {
    showDialog(
      context: context,
          child: new AlertDialog(
              title: new Text("Workspace ID"),
              content: new Form(
                key: _formKey,
                child: new TextFormField(
                  decoration: new InputDecoration(
                    labelText: '${user.email}#',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (String value) {
                    workspaceId = value;
                  },
                  validator: _validateWorkspaceId,
                  autofocus: true,
                ),
              ),
              actions: [
            new FlatButton(
              child: new Text("CANCEL"),
              onPressed: () => Navigator.pop(context),
            ),
            new FlatButton(
              child: new Text("PUBLISH"),
              onPressed: _publishItems,
            ),
          ]),
    );
  }

  Future<bool> _publishItems() async {
    final FormState form = _formKey.currentState;
    form.save();

    if (!form.validate()) {
      return false;
    }

    Navigator.pop(context);

    inventory.post(workspaceId);
    inventory.published = 'true';
    _bottomBarIndex();
    inventory.save(widget.name);
    setState(() => _snackBar('Inventory successfully published'));
    return true;
  }

  Future<bool> _uploadItems() async {
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

      if (inventory.items[itemIndex].uploaded == 'true') {
        continue;
      }

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
          item.progress = (photoIndex + 1) / item.photos.length;
        });
      }

      setState(() {
        item.progress = 1.0;
        item.uploading = 'false';
        inventory.items[itemIndex].uploaded = 'true';
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
      _bottomBarIndex();
    });

    return true;
  }

  int _bottomBarIndex() {
    if (inventory.published == 'true') {
      setState(() => _bottomIndex = 2);
      return 2;
    }

    if (inventory.uploaded == 'true') {
      setState(() => _bottomIndex = 1);
      return 1;
    }

    setState(() => _bottomIndex = 0);
    return 0;
  }

  bool _bottomBar(choice) {
    if (user.ftpValid == 'false') {
      _snackBar('Cannot upload or publish without valid FTP info');
      return true;
    }
    if (choice == 0) {
      if (inventory.uploading == 'true') {
        _cancelUpload();
      } else {
        _uploadItems();
      }
      return true;
    }

    if (choice == 1) {
      if (inventory.uploaded != 'true') {
        _snackBar('You must upload photos first.');
        return true;
      }
      _publishDialog();
      return true;
    }

    if (choice == 2) {
      // we need to prompt them to make sure
      _removeDialog();
      return true;
    }
  }

  void _removeDialog() {
    showDialog(
      context: context,
      child: new AlertDialog(
          title: new Text('Confirmation'),
          content:
              new Text('Are you sure you want to delete "${widget.name}?"'),
          actions: [
            new FlatButton(
              child: new Text("CANCEL"),
              onPressed: () => Navigator.pop(context),
            ),
            new FlatButton(
              child: new Text("DELETE"),
              onPressed: _removeInventory,
            ),
          ]),
    );
  }

  Future<Null> _removeInventory() async {
    Navigator.pop(context);
    await inventories.remove(widget.name);
    Navigator.pop(context);
    _snackBar('Inventory Removed');
  }

  Future<bool> _onWillPop() async => inventory.uploading == 'false';

  @override
  Widget build(BuildContext context) {
    if (!_loaded) loadInventory();
    if (!_loadedSignal) loadSignal();

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: new Text(widget.name), actions: [
          new Icon(_connection),
        ]),
        body: _body(),
        floatingActionButton: new FloatingActionButton(
          tooltip: 'Add',
          child: new Icon(Icons.add),
          onPressed: _toInventoryCreate,
        ),
        bottomNavigationBar: new BottomNavigationBar(
            onTap: _bottomBar,
            currentIndex: _bottomIndex,
            items: [
              new BottomNavigationBarItem(
                icon: new Icon(inventory.uploading == 'true'
                    ? Icons.cancel
                    : Icons.file_upload),
                title: new Text(inventory.uploading == 'true'
                    ? 'Cancel Upload'
                    : 'Upload Photos'),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(Icons.cloud_upload),
                title: new Text('Publish Inventory'),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(Icons.delete_forever),
                title: new Text('Remove Inventory'),
              ),
            ]),
      ),
    );
  }
}

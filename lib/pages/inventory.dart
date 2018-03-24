import 'dart:io';

import 'package:flutter/material.dart';
import '../HomeDrawer.dart';
import '../InventoryData.dart';
import 'inventoryModify.dart';
import 'package:connectivity/connectivity.dart';

class Inventory extends StatefulWidget {
  @override
  InventoryState createState() => new InventoryState();
}

class InventoryState extends State<Inventory> {

  var _loadedInv = false;
  var _loadedSignal = false;
  var _signalSubscription;
  var _connection = Icons.signal_cellular_connected_no_internet_4_bar;
  var _internet = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  loadInventory () async {
    await inventory.load();
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


  body () {
    if (_loadedInv) {
      if (inventory.items.length < 1) {
        return new Center(
          child: new Text('You have no inventory yet', style: new TextStyle(fontSize: 20.0),));
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
        if (inventory.uploading == 'true') {
          return _listProgressTile(item);
        } else {
          return _listProgressTile(item);
          // return _listTile(item);
        }
      }).toList(),
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
                child: new Image.file(new File(photo.path), fit: BoxFit.cover),
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
  _snackBar(message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
    ));
  }

  _uploadItems () async {
    if (inventory.items.length < 1) {
      _snackBar('You have no inventory yet');
      return true;
    }
    if (_internet == false) {
      _snackBar('Internet is required to upload inventory');
      return null;
    }

    if (inventory.uploading == 'false') {

      setState(() {
        inventory.uploading = 'true';
        _snackBar('Starting upload process');
      });

      for (var itemIndex = 0; itemIndex < inventory.items.length; itemIndex++) {

        InventoryItem item = inventory.items[itemIndex];
        setState(() { item.uploading = 'true'; });

        for (var photoIndex = 0; photoIndex < item.photos.length; photoIndex++) {
          InventoryItemPhoto photo = item.photos[photoIndex];
          await photo.upload('${itemIndex+1}-${photoIndex+1}');
          setState(() {
            item.progress = (photoIndex+1)/item.photos.length;
            print(item.progress);
          });
        }

        setState(() {
          item.progress = 1.0;
          item.uploading = 'false';
          item.uploaded = 'true';
          inventory.save();
          _snackBar('Images for ${item.name} saved');
        });

      }

      setState(() {
        inventory.uploading = 'false';
        _snackBar('Upload process complete');
      });

      return true;
    }

    setState(() {
      inventory.uploading = 'false';
      _snackBar('Canceling upload process');
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {

    if (!_loadedInv) loadInventory();
    if (!_loadedSignal) loadSignal();

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Inventory'),
        actions: <Widget>[
          new FlatButton(
            onPressed: null,
            child:
              new FlatButton.icon(
                onPressed: _uploadItems,
                icon: new Icon(_connection, color: _internet ? Colors.white : Colors.white30),
                label: new Text(
                  'UPLOAD',
                  style: new TextStyle(color: _internet && inventory.uploading == 'false' ? Colors.white : Colors.white30)),
              )
          )
        ],
      ),
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

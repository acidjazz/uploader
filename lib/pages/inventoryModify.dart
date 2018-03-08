import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../InventoryData.dart';

enum Mode { Create, Edit }

class InventoryModify extends StatefulWidget {

  final index;
  final item;

  InventoryModify(this.index, this.item);

  final String titleNew = 'Adding Inventory';
  final String titleEdit = 'Modifying inventory';

  @override
  InventoryModifyState createState() => new InventoryModifyState();

}

class InventoryModifyState extends State<InventoryModify> {

  Mode get mode => widget.index == null ? Mode.Create : Mode.Edit;
  InventoryItem _item;
  InventoryItem get item => _item ??= (widget.index == null ? new InventoryItem() : widget.item);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  ScrollController _gridController = new ScrollController();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
    ));
  }

  addPhoto () async {

    var _file = await ImagePicker.pickImage(source: ImageSource.askUser);

    setState(() { item.photos.add(_file.path); });

    await new Future.delayed(const Duration(milliseconds: 300), () => "1");
    _gridController.animateTo(
      _gridController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  removePhoto (photo) {
    setState(() { item.photos.remove(photo); });
    showInSnackBar('Photo removed');
  }

  String _validateName(String value) {
    if (value.isEmpty)
      return 'Inventory name is required';
    return null;
  }

  String _validatePhotos() {
    if (item.photos.length < 1)
      return 'Please select at least one photo';
    return null;
  }

  save () async {
    final FormState form = _formKey.currentState;
    form.save();

    if (!form.validate()) {
      showInSnackBar('Please fill out required fields');
    } else if (_validatePhotos() != null) {
      showInSnackBar(_validatePhotos());
    } else {
      showInSnackBar('Saving new inventory');
      if (mode == Mode.Create) {
        inventory.items.add(item);
      } else {
        inventory.items[widget.index] = item;
      }
      await inventory.save();
      Navigator.pop(context);
    }
  }

  void _remove (choice) async {
    showInSnackBar('Removing Item..');
    inventory.items.remove(item);
    await inventory.save();
    Navigator.pop(context);
  }

  Widget addPhotosWidget () {
    return new GestureDetector(
      onTap: () { addPhoto(); },
      child: new GridTile(
        child: new Container(
          child: new Icon(Icons.add_a_photo, size: 30.0, color: Colors.blue),
            decoration: new BoxDecoration(
              border: new Border.all(width: 1.0, color: Colors.blue),
              /*
              color: Colors.white,
              border: new Border.all(width: 1.0, color: Colors.blue),
              borderRadius: new BorderRadius.all(new Radius.circular(1.0)),
              boxShadow: [ new BoxShadow(color: Colors.blue, blurRadius: 3.0) ],
              var*/
          ),
        ),
      ),
    );
  }

  List<Widget> photosWidget () {

    var photos = item.photos.map((String photo) {
      return new GridTile(
        header: new GestureDetector(
          onTap: () { removePhoto(photo); },
          child: new GridTileBar(
            leading: new Container(
              padding: new EdgeInsets.all(6.0),
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.all(new Radius.circular(1.0)),
                color: Colors.black38
              ),
              child: new Icon(Icons.delete, color: Colors.white),
            ),
          ),
        ),
        child: new Container(
          child: new Image.file(new File(photo), fit: BoxFit.cover),
          decoration: new BoxDecoration(
            border: new Border.all(width: 1.0, color: Colors.black38),
          ),
        ),
      );
    }).toList();
    photos.add(addPhotosWidget());
    return photos;
  }

  @override
  Widget build(BuildContext context) {

    final Orientation orientation = MediaQuery.of(context).orientation;

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Colors.grey,
        title: new Text(mode == Mode.Edit ? widget.titleEdit : widget.titleNew),
        actions: <Widget>[
          new FlatButton(
            onPressed: save,
            child: new Text('SAVE', style: const TextStyle(color: Colors.white)),
          ),
          new PopupMenuButton(
            onSelected: _remove,
            itemBuilder: (BuildContext context) {
              return [
                new PopupMenuItem (
                  value: 'delete',
                  child: new Text('Delete'),
                )
              ];
            },
          ),
        ],

      ),
      body: new SafeArea(
        child: new Form(
          key: _formKey,
          child: new Container(
            padding: new EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
            child: new ListView(
              reverse: true,
              shrinkWrap: true,
              children: <Widget>[

                new Container(
                  padding: new EdgeInsets.symmetric(vertical: 20.0),
                  height: MediaQuery.of(context).size.height*0.3,
                  child: new GridView.count(
                    controller: _gridController,
                    crossAxisCount: 1,
                    scrollDirection: Axis.horizontal,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    padding: const EdgeInsets.all(4.0),
                    childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
                    children: photosWidget()
                  ),
                ),

                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.gavel),
                    hintText: 'Your Item name',
                    labelText: 'Item Name',
                  ),
                  initialValue: item.name == null ? '' : item.name,
                  onSaved: (String value) { item.name = value; },
                  validator: _validateName,
                ),

                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.assignment),
                    hintText: 'Describe your item',
                    labelText: 'Item Description',
                  ),
                  maxLines: null,
                  initialValue: item.description == null ? '' : item.description,
                  onSaved: (String value) { item.description = value; },
                ),

                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.label),
                    hintText: 'Item Category',
                    labelText: 'Category',
                  ),
                  initialValue: item.category == null ? '' : item.category,
                  onSaved: (String value) { item.category = value; },
                ),

              ].reversed.toList(),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../InventoryData.dart';

class InventoryModify extends StatefulWidget {
  var id = false;
  InventoryModify(this.id);

  final String titleNew = 'Adding Inventory';
  final String titleEdit = 'Modifying inventory';

  @override
  InventoryModifyState createState() => new InventoryModifyState();

}

class InventoryModifyState extends State<InventoryModify> {

  InventoryItem item = new InventoryItem();
  List<String> photos = new List();

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
    setState(() { this.photos.add(_file.path); });

    await new Future.delayed(const Duration(milliseconds: 300), () => "1");
    _gridController.animateTo(
      _gridController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  removePhoto (photo) {
    setState(() {
      this.photos.remove(photo);
    });
    showInSnackBar('Photo removed');
  }

  String _validateName(String value) {
    if (value.isEmpty)
      return 'Inventory name is required';
    return null;
  }

  String _validatePhotos() {
    if (photos.length < 1)
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
      item.photos = photos;
      inventory.items.add(item);
      await inventory.save();
    }
  }


  Widget addPhotosWidget () {
    return new GestureDetector(
      onTap: () { addPhoto(); },
      child: new GridTile(
        child: new Container(
          child: new Icon(Icons.add_a_photo, size: 30.0, color: Colors.blue),
            decoration: new BoxDecoration(
              /*
              color: Colors.white,
              border: new Border.all(width: 1.0, color: Colors.blue),
              borderRadius: new BorderRadius.all(new Radius.circular(1.0)),
              boxShadow: [ new BoxShadow(color: Colors.blue, blurRadius: 3.0) ],
              */
          ),
        ),
      ),
    );
  }

  List<Widget> photosWidget () {
   var photos = this.photos.map((String photo) {
      return new GridTile(
        header: new GestureDetector(
          onTap: () { removePhoto(photo); },
          child: new GridTileBar(
            leading: new Container(
              decoration: new BoxDecoration(
                color: Colors.white30
              ),
              child: new Icon(Icons.delete, color: Colors.blue),
            ),
          ),
        ),
        child: new Image.file(new File(photo), fit: BoxFit.cover),
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
        title: new Text(widget.id ? widget.titleEdit : widget.titleNew),
        actions: <Widget>[
          new FlatButton(
            onPressed: save,
            child: new Text('SAVE', style: const TextStyle(color: Colors.white)),
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

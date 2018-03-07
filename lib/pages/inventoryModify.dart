import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InventoryModify extends StatefulWidget {
  var id = false;
  InventoryModify(this.id);

  final String titleNew = 'Adding Inventory';
  final String titleEdit = 'Modifying inventory';

  @override
  InventoryModifyState createState() => new InventoryModifyState();

  save () {
    print('saving new inventory');
  }

}

class InventoryModifyState extends State<InventoryModify> {

  List<File> photos = new List();

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
    setState(() { this.photos.add(_file); });

    await new Future.delayed(const Duration(milliseconds: 300), () => "1");
    // showInSnackBar('Photo added');
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

  Widget addPhotosWidget () {
    return new GestureDetector(
      onTap: () { addPhoto(); },
      child: new GridTile(
        child: new Container(
          child: new Icon(Icons.add_a_photo, size: 30.0, color: Colors.blue),
            decoration: new BoxDecoration(
              border: new Border.all(width: 1.0, color: Colors.blue),
              borderRadius: new BorderRadius.all(new Radius.circular(1.0)),
              color: Colors.white,
              boxShadow: [
                new BoxShadow(color: Colors.blue, blurRadius: 3.0)
              ],
          ),
        ),
      ),
    );
  }

  List<Widget> photosWidget () {
   var photos = this.photos.map((File photo) {
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
        child: new Image.file(photo, fit: BoxFit.cover),
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
            onPressed: widget.save,
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
                ),

                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.assignment),
                    hintText: 'Describe your item',
                    labelText: 'Item Description',
                  ),
                  maxLines: null,
                ),

                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.label),
                    hintText: 'Item Category ',
                    labelText: 'Category',
                  ),
                ),

              ].reversed.toList(),
            ),
          ),
        ),
      ),
    );
  }
}

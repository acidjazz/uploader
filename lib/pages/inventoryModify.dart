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

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  choosePhotos () async {
    var _file = await ImagePicker.pickImage();
    setState(() {
      this.photos.add(_file);
      print('PHOTO PATH');
      print(this.photos.first.path);
    });
  }

  List<Widget> photosWidget () {
    return this.photos.map((File photo) {
      return new Container(
        padding: new EdgeInsets.symmetric(horizontal: 10.0),
        child: new Image.file(photo, width: 100.0),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                new RaisedButton(
                  onPressed: choosePhotos,
                  child: new Text('Add Photos'),
                  color: Colors.blue,
                  textColor: Colors.white,
                ),

                new Container(
                  padding: new EdgeInsets.symmetric(vertical: 20.0),
                  height: MediaQuery.of(context).size.height*0.2,
                  child: new ListView(
                    scrollDirection: Axis.horizontal,
                    children: photos.length == 0
                      ? [ new Text('No image selected yet') ]
                      : photosWidget()
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

              ],
            ),
          ),
        ),
      ),
    );
  }
}

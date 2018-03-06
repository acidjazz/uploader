import 'package:flutter/material.dart';

class InventoryModify extends StatefulWidget {
  var id = false;
  InventoryModify(this.id);

  String titleNew = 'Adding Inventory';
  String titleEdit = 'Modifying inventory';

  @override
  InventoryModifyState createState() => new InventoryModifyState();

  save () {
    print('saving new inventory');
  }

  choosePhotos () {
    print('choosing photos');
  }
}

class InventoryModifyState extends State<InventoryModify> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

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
              children: <Widget>[

                new RaisedButton(
                  onPressed: widget.choosePhotos,
                  child: new Text('Add Photos'),
                  color: Colors.blue,
                  textColor: Colors.white,
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

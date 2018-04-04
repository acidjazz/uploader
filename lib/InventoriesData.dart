import 'dart:async';
import 'dart:convert';
import 'package:maxanet_uploader/InventoryData.dart';
import 'package:shared_preferences/shared_preferences.dart';


class InventoriesData {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<InventoriesItem> items;

  static final InventoriesData _singleton = new InventoriesData._internal();
  InventoriesData._internal();

  static InventoriesData get instance => _singleton;

  Future<bool> save() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setStringList('inventories', inventories.itemsToJson());
    await new Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> load() async {
    print('initiating inventories.load()');
    final SharedPreferences prefs = await _prefs;
    if (prefs.getStringList('inventories') == null) {
      inventories.items = new List<InventoriesItem>();
    } else {
      inventories.items = jsonToItems(prefs.getStringList('inventories'));
    }

    for (var i = 0; i < inventories.items.length; i++) {
      inventories.items[i].data = await inventory.load(inventories.items[i].name);
    }
    /*
    inventories.items.map((item) async {
      item.data = await inventory.load(item.name);
    });
    */

    await new Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> remove(name) async {
    await inventory.remove(name);
    inventories.items.remove(name);
    await inventories.save();
    return true;
  }

  itemsToJson() {
    return inventories.items.map((InventoriesItem item) {
      return item.toJson();
    }).toList(growable: true);
  }

  jsonToItems(items) {
    return items.map((item) {
      return new InventoriesItem.fromJson(item);
    }).toList(growable: true);
  }

}

class InventoriesItem extends JsonDecoder {
  String name;
  List<InventoryItem> data;
  InventoriesItem(this.name);

  stats () {
    if (this.data == null) {
      return 'nothing found';
    }
    int items = this.data.length;
    int photos = 0;
    for (int i = 0; i < this.data.length; i++) {
      photos += this.data[i].photos.length;
    }

    return '$items items wtih $photos photos';
  }

  InventoriesItem.fromJson(Map<String, dynamic> json)
    : name = json['name'];
  Map<String, dynamic> toJson() =>
    { 'name': name, };
}

var inventories = new InventoriesData._internal();
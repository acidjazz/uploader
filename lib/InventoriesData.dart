import 'dart:async';
import 'dart:convert' show json;
import 'package:maxanet_uploader/InventoryData.dart';
import 'package:shared_preferences/shared_preferences.dart';

var inventories = new InventoriesData._();

class InventoriesData {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<InventoriesItem> items = new List<InventoriesItem>();
  static const Key = 'inventories';

  InventoriesData._();

  Map<String, dynamic> toJson() => {'items': items};

  List<InventoriesItem> fromJson(Map<String, dynamic> json) {
    List<InventoriesItem> items;
    if (json == null) {
      items = <InventoriesItem> [];
    } else {
      items = (json['items'] as List<dynamic>).map((item) =>
        new InventoriesItem.fromJson(item as Map<String, dynamic>) ).toList();
    }
    return items;
  }

  Future<bool> save() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString(Key, json.encode(inventories));
    return true;
  }

  Future<bool> load() async {
    final SharedPreferences prefs = await _prefs;
    final result = prefs.getString(Key);

    if (result == null) {
      return false;
    }

    items = fromJson(json.decode(result));

    for (var i = 0; i < inventories.items.length; i++) {
      inventories.items[i].data = await inventory.load(inventories.items[i].name);
      inventories.items[i].uploaded = inventory.uploaded;
      inventories.items[i].published = inventory.published;
    }

    return true;
  }

  Future<bool> remove(name) async {
    await inventory.remove(name);

    for (var i = 0; i < inventories.items.length; i++) {
      if (name == inventories.items[i].name) {
        inventories.items.removeAt(i);
      }
    }

    await inventories.save();
    return true;
  }

}

class InventoriesItem {

  String name;
  String uploaded;
  String published;
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

    String status = 'ready to upload';

    if (this.uploaded == 'true') {
      status = 'uploaded';
    }

    if (this.published == 'true') {
      status = 'published';
    }

    return '$items items, $photos photos, $status';
  }

  Map<String, dynamic> toJson() => {'name': name };

  factory InventoriesItem.fromJson(json) => new InventoriesItem(json['name']);

}


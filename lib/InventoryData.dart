import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryData {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<InventoryItem> items;

  static final InventoryData _singleton = new InventoryData._internal();
  InventoryData._internal();
  static InventoryData get instance => _singleton;

  Future<bool> save () async {
    final SharedPreferences prefs = await _prefs;
    prefs.setStringList('inventory', inventory.itemsToJson());
    await new Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> load () async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getStringList('inventory') == null) {
      inventory.items = new List<InventoryItem>();
    } else {
      inventory.items = jsonToItems(prefs.getStringList('inventory'));
    }
    await new Future.delayed(const Duration(seconds: 1));
    return true;
  }

  itemsToJson() {
    return inventory.items.map((InventoryItem item) {
      return item.toJson();
    }).toList(growable: true);
  }

  jsonToItems(items) {
    return items.map((item) {
      return new InventoryItem.fromJson(item);
    }).toList(growable: true);
  }

}

class InventoryItem extends JsonDecoder {

  List<String> photos = <String>[];
  String name;
  String description;
  String category;

  InventoryItem();

  InventoryItem.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      description = json['description'],
      category = json['category'],
      photos = json['photos'].toList();

  Map<String, dynamic> toJson() =>
    {
      'name': name,
      'description': description,
      'category': category,
      'photos': photos,
    };
}

var inventory = new InventoryData._internal();

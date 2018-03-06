import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryData {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Object> Inventory = new List();


  static final InventoryData _singleton = new InventoryData._internal();
  InventoryData._internal();
  static InventoryData get instance => _singleton;

  Future<bool> save () async {
    final SharedPreferences prefs = await _prefs;
    // serialize our complex array
    return true;
  }

}

var inventory = new InventoryData._internal();

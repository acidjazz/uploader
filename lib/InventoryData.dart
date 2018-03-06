import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryData {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List Inventory = [];

  Future<bool> save () async {
    final SharedPreferences prefs = await _prefs;
    // serialize our complex array
    return true;
  }

}
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class InventoryData {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<InventoryItem> items;

  static final InventoryData _singleton = new InventoryData._internal();
  InventoryData._internal();
  static InventoryData get instance => _singleton;

  bool uploading = false;

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

  List<InventoryItemPhoto> photos = <InventoryItemPhoto>[];
  String name;
  String description;
  String category;
  bool uploaded = false;

  InventoryItem();

  InventoryItem.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      description = json['description'],
      category = json['category'],
      photos = InventoryItemPhoto.jsonToPhotos(json['photos'].toList());

  Map<String, dynamic> toJson() =>
    {
      'name': name,
      'description': description,
      'category': category,
      'photos': InventoryItemPhoto.photosToJson(photos),
    };
}

class InventoryItemPhoto extends JsonDecoder {

  String path;
  String url;

  InventoryItemPhoto(this.path, this.url);

  InventoryItemPhoto.fromJson(Map<String, dynamic> json)
    : path = json['path'], url = json['url'];

  Map<String, dynamic> toJson() =>
    { 'path': path, 'url': url, };


  static photosToJson(photos) {
    return photos.map((InventoryItemPhoto photo) {
      return photo.toJson();
    }).toList(growable: true);
  }

  static jsonToPhotos(photos) {
    return photos.map((photo) {
      return new InventoryItemPhoto.fromJson(photo);
    }).toList(growable: true);
  }

  upload (progress, result) async {
    final File file = new File(this.path);
    final StorageReference ref =
      FirebaseStorage.instance.ref().child(this.path);
    final StorageUploadTask uploadTask = ref.put(file);
    final Uri downloadUrl = (await uploadTask.future).downloadUrl;
    this.url = downloadUrl.path;
  }

}

var inventory = new InventoryData._internal();

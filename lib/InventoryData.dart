import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class InventoryData {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<InventoryItem> items;

  Directory appDoc;

  static final InventoryData _singleton = new InventoryData._internal();

  InventoryData._internal();

  static InventoryData get instance => _singleton;

  String uploading = 'false';

  Future<bool> save (name) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setStringList(name, inventory.itemsToJson());
    await new Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<List> load (name) async {
    List<InventoryItem> items;
    final SharedPreferences prefs = await _prefs;
    if (prefs.getStringList(name) == null) {
      items = new List<InventoryItem>();
    } else {
      items = jsonToItems(prefs.getStringList(name));
    }
    inventory.items = items;
    await new Future.delayed(const Duration(seconds: 1));
    appDoc = await getApplicationDocumentsDirectory();
    return items;
  }

  Future<bool> remove (name) async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove(name);
    return true;
  }

  path(file) {
    return '${appDoc.path}/$file';
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

  toCSV () {

    List row = [];
    for (var itemIndex = 0; itemIndex < this.items.length; itemIndex++) {
      InventoryItem item = this.items[itemIndex];
      List photos = [];
      List thumbnails = [];
      for (var photoIndex = 0; photoIndex < item.photos.length; photoIndex++) {
        InventoryItemPhoto photo = item.photos[photoIndex];
        photos.add(photo.url);
        thumbnails.add(photo.thumbnail);
      }
      row.add('${itemIndex + 1}|${item.category}|${item.description}||${photos.join(' ')}||1|${thumbnails.join(' ')}|');
    }
    return row.join('\r\n');

  }

  post () async {

    final Uri uri = Uri.parse("https://www.maxanet.com/cgi-bin/mrnewinv.cgi");
    final request = new http.MultipartRequest("POST", uri);

    request.fields['auction'] = 'exampled';
    request.fields['remotepw'] = 'nexd123pw4';
    request.fields['delimiter'] = '|';
    request.fields['submit'] = '1';
    request.files.add(new http.MultipartFile.fromString(
      'filename',  this.toCSV(),
      filename: 'csv.txt',
      contentType: new MediaType('application', 'text/plain'),
    ));

    request.send().then((response) {
      response.stream.transform(UTF8.decoder).listen((data) {
        print(data);
      });
    });

  }

}

class InventoryItem extends JsonDecoder {

  List<InventoryItemPhoto> photos = <InventoryItemPhoto>[];
  String name;
  String description;
  String category;
  String uploaded = 'false';

  String uploading = 'false';
  double progress = 0.0;

  InventoryItem();

  InventoryItem.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      description = json['description'],
      category = json['category'],
      uploaded = json['uploaded'],
      progress = json['progress'],
      photos = InventoryItemPhoto.jsonToPhotos(json['photos'].toList());

  Map<String, dynamic> toJson() =>
    {
      'name': name,
      'description': description,
      'category': category,
      'uploaded': uploaded,
      'progress': progress,
      'photos': InventoryItemPhoto.photosToJson(photos),
    };
}

class InventoryItemPhoto extends JsonDecoder {

  String path;
  String url;
  String thumbnail;


  InventoryItemPhoto(this.path, this.url, this.thumbnail);

  InventoryItemPhoto.fromJson(Map<String, dynamic> json)
    : path = json['path'],
      url = json['url'],
      thumbnail = json['thumbnail'];

  Map<String, dynamic> toJson() =>
    { 'path': path, 'url': url, 'thumbnail': thumbnail};


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

  upload(index) async {

    // w/out isolation a delay helps w/ progress bars
    // await new Future.delayed(const Duration(seconds: 1));

    // grabbing the file as a whole
    // final File file = new File(inventory.path(this.path));

    // grabbing the file via a package that compresses it natively for speed purposes

    final File file = await FlutterNativeImage.compressImage(inventory.path(this.path),
      quality: 80,
      percentage: 50);

    // running decodeImage() in isolation due to delay
    ReceivePort receivePort = new ReceivePort();
    await Isolate.spawn(decode, new DecodeParam(file, receivePort.sendPort));
    Image image = await receivePort.first;


    // running deocdeImage() inline freezes the app/prgoress
    // Image image = decodeImage(file.readAsBytesSync());

    this.thumbnail =
    await uploadFile('$index-thumbnail-${file.uri.pathSegments.last.replaceAll('_compressed', '')}',
      copyResize(image, 240), file.parent.path);

    this.url = await uploadFile('$index-${file.uri.pathSegments.last.replaceAll('_compressed', '')}',
      copyResize(image, 640), file.parent.path);

    return true;
  }

  static void decode(DecodeParam param) {
    Image image = decodeImage(param.file.readAsBytesSync());
    param.sendPort.send(image);
  }

  uploadFile(name, image, path) async {
    new File('$path/$name').writeAsBytesSync(encodeJpg(image));
    File file = new File('$path/$name');

    final StorageReference ref =
      FirebaseStorage.instance.ref().child('folder/$name');
    final StorageUploadTask uploadTask = ref.put(file);
    final Uri downloadUrl = (await uploadTask.future).downloadUrl;
    file.delete();
    return downloadUrl.path;
  }

}

class DecodeParam {
  final File file;
  final SendPort sendPort;
  DecodeParam(this.file, this.sendPort);
}

var inventory = new InventoryData._internal();

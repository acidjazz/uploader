import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:maxanet_uploader/UserData.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String uploaded = 'false';
  String published = 'false';
  String cancel = 'false';

  Future<bool> save (name) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setStringList(name, inventory.itemsToJson());
    prefs.setString('$name-uploaded', inventory.uploaded);
    prefs.setString('$name-published', inventory.published);
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
    inventory.uploaded = prefs.getString('$name-uploaded');
    inventory.published = prefs.getString('$name-published');
    appDoc = await getApplicationDocumentsDirectory();
    return items;
  }
  String next () {
    int index = 0;
    for (InventoryItem item in inventory.items) {
      if (int.parse(item.number) > index) {
        index = int.parse(item.number);
      }
    }
    index++;
    return index.toString();
  }
  bool exists (number) {
    for(InventoryItem item in inventory.items) {
      if (item.number == number)
        return true;
    }
    return false;
  }

  int count (number) {
    int items = 0;
    for (InventoryItem item in inventory.items) {
      if (item.number == number)
        items++;
    }
    return items;
  }

  Future<bool> remove (name) async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove(name);
    return true;
  }

  String path(file) {
    return '${appDoc.path}/$file';
  }

  List<String> itemsToJson() {
    return inventory.items.map((InventoryItem item) {
      return json.encode(item.toJson());
    }).toList();
  }

  List<InventoryItem> jsonToItems(List<String> items) {
    return items.map((item) => new InventoryItem.fromJson(json.decode(item))).toList();
  }

  toCSV () {

    List row = [];
    for (var itemIndex = 0; itemIndex < this.items.length; itemIndex++) {
      var item = this.items[itemIndex];
      List photos = [];
      List thumbnails = [];
      for (var photoIndex = 0; photoIndex < item.photos.length; photoIndex++) {
        var photo = item.photos[photoIndex];
        photos.add(photo.url);
        thumbnails.add(photo.thumbnail);
      }
      //item|category|desc|moredesc|photos|taxable?|startingBid|thumbnails|reserve|quantity|seller|buynow
      row.add('${item.number}|${item.category}|${item.description}||${photos.join(' ')}||${item.startingBid}|${thumbnails.join(' ')}|${item.reservePrice}|${item.quantity}||${item.buyNowPrice}');
    }
    return row.join('\r\n');

  }

  post (workspace, respond) async {

    await user.load();

    print('publish detail:');
    print('url: ${user.publishURL}');
    print('auction: ${user.email}$workspace');
    print('remotepw: ${user.password}');
    print('file:');;
    print(this.toCSV());


    final Uri uri = Uri.parse(user.publishURL);
    final request = new http.MultipartRequest("POST", uri);

    // request.fields['auction'] = 'exampled';
    request.fields['auction'] = '${user.email}$workspace';
    request.fields['remotepw'] = user.password;
    request.fields['delimiter'] = '|';
    request.fields['submit'] = '1';
    request.files.add(new http.MultipartFile.fromString(
      'filename',  this.toCSV(),
      filename: 'csv.txt',
      contentType: new MediaType('application', 'text/plain'),
    ));

    request.send().then((response) {
      response.stream.transform(UTF8.decoder).listen((data) {
        respond(data
          .replaceAll(new RegExp("<[^>]*>"), '')
          .replaceAll("\n", '')
          .replaceAll('Maxanet File Upload', '')
          .trim());
      });
    });

  }

}

class InventoryItem {

  List<InventoryItemPhoto> photos = [];
  String number;

  String description;
  String category;
  String startingBid;
  String reservePrice;
  String quantity;
  String buyNowPrice;

  String uploaded = 'false';
  String uploading = 'false';
  double progress = 0.0;

  InventoryItem();

  InventoryItem.fromJson(Map<String, dynamic> json)
    : number = json['number'],

      description = json['description'],
      category = json['category'],
      startingBid = json['startingBid'],
      reservePrice = json['reservePrice'],
      quantity = json['quantity'],
      buyNowPrice = json['buyNowPrice'],

      uploaded = json['uploaded'],
      progress = json['progress'],
      photos = InventoryItemPhoto.fromList(json['photos'] as List<dynamic>);

  Map<String, dynamic> toJson () =>
    {
      'number': number,

      'description': description,
      'category': category,
      'startingBid': startingBid,
      'reservePrice': reservePrice,
      'quantity': quantity,
      'buyNowPrice': buyNowPrice,

      'uploaded': uploaded,
      'progress': progress,
      'photos': photos,
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

  Map<String, dynamic> toJson () =>
    { 'path': path, 'url': url, 'thumbnail': thumbnail };

  static List<InventoryItemPhoto> fromList(List<dynamic> photos) =>
    photos.map((photo) =>
      new InventoryItemPhoto.fromJson(photo as Map<String, dynamic>)).toList();

  upload(name, number) async {

    // grabbing the file as a whole
    // final File file = new File(inventory.path(this.path));


    /* running decodeImage() in isolation due to delay
    ReceivePort receivePort = new ReceivePort();
    await Isolate.spawn(decode, new DecodeParam(file, receivePort.sendPort));
    Image image = await receivePort.first;
    */

    // running decodeImage() inline freezes the app/prgoress
    // Image image = decodeImage(file.readAsBytesSync());

    /*
    this.thumbnail =
    await uploadFile('$number-thumbnail-${file.uri.pathSegments.last.replaceAll('_compressed', '')}',
      copyResize(image, 240), file.parent.path);

    this.url = await uploadFile('$index-${file.uri.pathSegments.last.replaceAll('_compressed', '')}',
      copyResize(image, 640), file.parent.path);
    */

    final File file = await FlutterNativeImage.compressImage(inventory.path(this.path),
      quality: 80,
      percentage: 50);
    // final File file = new File(inventory.path(this.path));

    await uploadFile(name, number, file.uri.pathSegments.last.split('.').last, file, file.parent.path);
    print(this.url);
    print(this.thumbnail);
    return true;
  }

  static void decode(DecodeParam param) {
    Image image = decodeImage(param.file.readAsBytesSync());
    param.sendPort.send(image);
  }

  Future<String> uploadFile(name, number, extension, file, path) async {

    // final Uri uri = new Uri.http("192.168.1.107:8000", "/upload");
    final Uri uri = new Uri.http("ec2-52-90-192-206.compute-1.amazonaws.com", "/upload");
    final request = new http.MultipartRequest("POST", uri);
    print('UPLOADING $number ${file.path}');

    request.fields['ftp-host'] = user.ftpHost;
    request.fields['ftp-user'] = user.ftpUsername;
    request.fields['ftp-password'] = user.ftpPassword;
    request.fields['file-name'] = number;
    request.fields['file-extension'] = extension;
    request.fields['workspace'] = user.email;
    request.fields['inventory-name'] = name;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    await request.send().then((response) {

      https://www.change.org/p/lg-please-revive-3d-on-a-2018-oled-tv-model
      response.stream.transform(UTF8.decoder).listen((data) {
        this.url = json.decode(data)['imageName'];
        this.thumbnail = json.decode(data)['thumbnailName'];
      });
    });

    return number;

  }

}

class DecodeParam {
  final File file;
  final SendPort sendPort;
  DecodeParam(this.file, this.sendPort);
}

var inventory = new InventoryData._internal();

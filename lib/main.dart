import 'package:flutter/material.dart';
import 'package:maxanet_uploader/pages/inventories.dart' show Inventories;
import 'pages/inventory.dart' show Inventory;
import 'pages/login.dart' show Login;
import 'pages/home.dart' show Home;

void main() => runApp(new Uploader());

class Uploader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Maxanet Uploader',
      home: new Center(child: new Login()),
      onGenerateRoute: (RouteSettings settings) {
        final List<String> path = settings.name.split('/');
        if (path[1]  != 'inventory') {
          return null;
        }
        print('WE GOING TO ${path[2]}');
        return new MaterialPageRoute(
          builder: (context) => new Inventory(path[2]),
        );
      },
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new Home(),
        '/login': (BuildContext context) => new Login(),
        '/inventories': (BuildContext context) => new Inventories(),
      },
    );
  }
}


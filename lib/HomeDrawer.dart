import 'dart:async';

import 'package:flutter/material.dart';
import 'UserData.dart' show user;

class HomeDrawer extends StatelessWidget {

  String routeName;
  HomeDrawer(this.routeName);

  Future<bool> _logOut (BuildContext context) async {
    final nav = Navigator.of(context);
    nav.pop();
    showInSnackBar(context, 'Logging out..');
    await user.reset();
    nav.pushNamedAndRemoveUntil('/login', (v) => false);
    return true;
  }

  void showInSnackBar(BuildContext context, String value) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(value),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
       child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text('firstName lastName'),
              accountEmail: new Text(user.email),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: const AssetImage('images/avatar.png'),
              ),
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage('images/pattern-box.png'),
                  repeat: ImageRepeat.repeat,

                ),
              ),
            ),
            new ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: new Text('Sign Out'),
              onTap: () => _logOut(context),
            ),
            new ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pushNamed(context, '/home'),
              selected: this.routeName == '/home',
            ),
            new ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Inventory'),
              onTap: () => Navigator.pushNamed(context, '/inventories'),
              selected: this.routeName == '/inventories',
            ),
          ],
        ),
      );
  }

}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'UserData.dart' show user;

class HomeDrawer extends StatefulWidget {

  String routeName;

  HomeDrawer(this.routeName);

  HomeDrawerState createState() => new HomeDrawerState();

  Future<bool> _logOut(BuildContext context) async {
    final nav = Navigator.of(context);
    nav.pop();
    showInSnackBar(context, 'Logging out..');
    await user.reset();
    nav.pushNamedAndRemoveUntil('/login', (v) => false);
    return true;
  }

  Future<void> _help(BuildContext context) async {
    const url = 'https://www.maxanet.com';
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      showInSnackBar(context, 'Cannot launch URL');
    }
  }

  Future<void> _admin(BuildContext context) async {
    String url = user.adminURL;
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      showInSnackBar(context, 'Cannot launch URL');
    }
  }

  void showInSnackBar(BuildContext context, String value) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(value),
    ));
  }

}

class HomeDrawerState extends State<HomeDrawer> {
  var _loaded = false;

  Future<void> loadUser() async {
    await user.load();
    setState(() { _loaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) loadUser();
    if (!_loaded) {
      return new Center(child: new CircularProgressIndicator());
    } else {
      return new Drawer(
        child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text('WorkGroup'),
              accountEmail: new Text(user.email),
              currentAccountPicture: null,
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
              onTap: () => widget._logOut(context),
            ),
            new ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pushNamed(context, '/home'),
              selected: widget.routeName == '/home',
            ),
            new ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Inventories'),
              onTap: () => Navigator.pushNamed(context, '/inventories'),
              selected: widget.routeName == '/inventories',
            ),
            new ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
              selected: widget.routeName == '/settings',
            ),
            new ListTile(
              leading: const Icon(Icons.help),
              title: new Text('Documentation / Tutorial'),
              onTap: () => widget._help(context),
            ),
            new ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: new Text('Admin URL'),
              onTap: () => widget._admin(context),
            ),
          ],
        ),
      );
    }
  }

}

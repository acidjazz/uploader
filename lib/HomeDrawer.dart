import 'package:flutter/material.dart';
import 'UserData.dart' show user;

class HomeDrawer extends StatelessWidget {

  bool _logOut () {
    Navigator.pop(context);
    showInSnackBar('Logging out..');
    user.reset().then((result) =>
      Navigator.of(context).pushReplacementNamed('/login'));
    return true;
  }


  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
       child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountEmail: new Text(user.email),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: const AssetImage('images/avatar.png'),
              ),
            ),
            new ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: _logOut,
            ),
            new ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Inventory'),
              onTap: () => Navigator.pushNamed(context, '/inventory'),
            ),
          ],
        ),
      );
  }

}

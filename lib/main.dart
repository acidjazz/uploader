
import 'package:flutter/material.dart';

void main() => runApp(new Uploader());

class Uploader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Maxanet Uploader',
      home: new Center(child: new Login()),
    );
  }
}

class Login extends StatefulWidget {
  @override
  LoginState createState() => new LoginState();
}

class UserData {
  String email = '';
  String password = '';
}

class LoginState extends State<Login> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Login to Maxanet'),
      ),
      body : new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
          child: new Container(
            padding: new EdgeInsets.symmetric(horizontal: 30.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Image.asset('images/icon-transparent-small.png', width: 100.0),
                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.email),
                    hintText: 'Email Address',
                    labelText: 'Email',
                  ),
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.lock),
                    hintText: 'Password',
                    labelText: 'Your Password',
                  ),
                  obscureText: true,
                ),
                new Container(
                  padding: const EdgeInsets.all(20.0),
                  alignment: Alignment.center,
                  child: new RaisedButton(
                    child: const Text('LOGIN'),
                    onPressed: () => {},
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

}
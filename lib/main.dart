
import 'package:flutter/material.dart';

void main() => runApp(new Uploader());

class Uploader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Maxanet Uploader',
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Login to Maxanet'),
        ),
        body: new Center(
          child: new Login(),
        ),
      ),
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
      body : new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
          child: new ListView(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.all(60.0),
                child: new Image.asset('/images/icon-transparent.png'),
              ),
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
      )
    );
  }

}
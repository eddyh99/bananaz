import 'package:devbananaz/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CustomerLogout extends StatefulWidget {
  @override
  _CustomerLogoutState createState() => _CustomerLogoutState();
}

class _CustomerLogoutState extends State<CustomerLogout> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  void doLogout()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.remove("user_id");
    await initiateFacebookLogout();
    await signOutGoogle();
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context)=>Login()
      )
    );
  }

  Future<void> initiateFacebookLogout()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.remove("facebookToken");
    prefs.remove("user_id");
    var _facebookLogin=FacebookLogin();
    await _facebookLogin.logOut();
    await _auth.signOut();
  }

  void signOutGoogle() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.remove("user_id");
    await googleSignIn.signOut();
    await _auth.signOut();
    print("User Sign Out");
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Center(
        child: new SingleChildScrollView(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                padding: EdgeInsets.all(8),
                child: new Icon(
                    Icons.all_out,
                  size: 50,
                  color: Colors.lightBlueAccent,
                ),
              ),
              new Text(
                  "Are you sure want to logout ?",
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              ),
              new Container(
                padding: new EdgeInsets.all(8),
                child: new RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)
                  ),
                  elevation: .4,
                  child: new Text(
                      "Logout",
                    style: new TextStyle(
                      color: Colors.white
                    ),
                  ),
                  onPressed:()async{
                    doLogout();
                  },
                  color: Colors.redAccent,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

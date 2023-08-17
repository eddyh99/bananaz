import 'package:devbananaz/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:devbananaz/pages.dart';
import 'package:url_launcher/url_launcher.dart';


const SecondaryColor =  Color(0xff62BBF9);
class CustomerLogout extends StatefulWidget {
  @override
  _CustomerLogoutState createState() => _CustomerLogoutState();
}

class _CustomerLogoutState extends State<CustomerLogout> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseMessaging _fcm = new FirebaseMessaging();

  void doLogout()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.remove("user_id");
    prefs.remove("id_customer");
    _fcm.unsubscribeFromTopic("bananaz");
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
      child: new Container(
        child: new SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.all(8),
              ),
              new Container(
                width: double.infinity,
                padding: new EdgeInsets.all(4),
                child: new RaisedButton(
                  onPressed: () {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) =>
                            PagesPush(
                                idPages: '1'
                            )
                    ));
                  },
                  child: new Text(
                    "Why Bananaz",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                  elevation: .4,
                  color: SecondaryColor,
                  textColor: Colors.white,
                ),
              ),
              new Container(
                width: double.infinity,
                padding: new EdgeInsets.all(4),
                child: new RaisedButton(
                  onPressed: () {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) =>
                            PagesPush(
                                idPages: '2'
                            )
                    ));
                  },
                  child: new Text(
                    "Privacy Policy",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                  elevation: .4,
                  color: SecondaryColor,
                  textColor: Colors.white,
                ),
              ),
              new Container(
                width: double.infinity,
                padding: new EdgeInsets.all(4),
                child: new RaisedButton(
                  onPressed: () {
                    launch("https://www.bananaz.co/kontak");
                  },
                  child: new Text(
                    "Contact Us",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                  elevation: .4,
                  color: SecondaryColor,
                  textColor: Colors.white,
                ),
              ),
              new Container(
                alignment: Alignment.center,
                padding: new EdgeInsets.all(8),
                child: new RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
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

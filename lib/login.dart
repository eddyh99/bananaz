import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart' as fl;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:devbananaz/main_home.dart';
import 'package:devbananaz/app2_book.dart';
import 'package:devbananaz/on_going_promo.dart';
import 'package:devbananaz/signup.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const PrimaryColor = Color(0xffFFC300);
const SecondaryColor = Color(0xff62BBF9);

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final Firestore _db = new Firestore();
  final FirebaseMessaging _fcm = new FirebaseMessaging();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
      });
      //_fcm.requestNotificationPermissions(IosNotificationSettings());
      _fcm.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true));
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }
    /*_fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("Message Message : $message");
        if(message["action_destination"]=="HomeActivity"){
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return new AlertDialog(
                  backgroundColor: PrimaryColor,
                  title: new Text(message["title"]),
                  content: new Text(message["message"]),
                  actions: <Widget>[
                    new FlatButton(
                      color: PrimaryColor,
                      textColor: Colors.white,
                      child: new Text("Close"),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                );
              });

        } else if(message["action_destination"]=="PromoActivity"){
          showDialog(
              context: context,
              builder: (BuildContext context)
              {
                return new AlertDialog(
                  backgroundColor: PrimaryColor,
                  title: new Text(message["title"]),
                  content: new Text(message["message"]),
                  actions: <Widget>[
                    new FlatButton(
                      color: PrimaryColor,
                      textColor: Colors.white,
                      child: new Text("Close"),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                );
              });

        }else{
          showDialog(
              context: context,
              builder: (BuildContext context)
              {
                return new AlertDialog(
                  backgroundColor: PrimaryColor,
                  title: new Text(message["title"]),
                  content: new Text(message["message"]),
                  actions: <Widget>[
                    new FlatButton(
                      color: PrimaryColor,
                      textColor: Colors.white,
                      child: new Text("Close"),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                );
              });
        }

      },
      onResume: (Map<String, dynamic> message) async {
        print("on Message1 : $message");

      },
      onLaunch: (Map<String, dynamic> message) async {
        print("on Message2 : $message");

      },
    );*/
  }

  _saveDeviceToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //String uid = prefs.getString("uid");

    String fcmToken = await _fcm.getToken();
    prefs.setString("fcmToken", fcmToken);
    print("Token Login Dart : " + fcmToken);
  }

  Future<String> signInWithGoogle() async {
    showDialog(
        builder: (context) => new Dialog(
              child: new Container(
                color: PrimaryColor,
                padding: EdgeInsets.all(10),
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(10),
                        child: Center(child: new CircularProgressIndicator())),
                    new Text(
                      "Redirecting ...",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        context: null);
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    try {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      //final FirebaseUser user = await _auth.signInWithCredential(credential);
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // token dari firebase

      print("Token dari main : " + prefs.getString("fcmToken"));
      var userToken = await user.getIdToken();
      var userExist = await emailExist(email: user.email);
      if (userExist) {
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (context) => MainHome()));
      } else {
        prefs.setString("email", user.email);
        prefs.setString("first_name", user.displayName);
        prefs.setString("phone_number", user.phoneNumber);
        //prefs.setString("android_id", userToken);
        prefs.setString("android_id", prefs.getString("fcmToken"));
        prefs.setString("uid", user.uid);
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) => SignUp(
                name: user.displayName,
                email: user.email,
                phoneNumber: user.phoneNumber,
                token: prefs.getString("fcmToken"))));
      }
      return 'signInWithGoogle succeeded: $user';
    } catch (NoSuchMethodError) {
      Navigator.pop(context);
    }
  }

  void signOutGoogle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("user_id");
    await googleSignIn.signOut();

    print("User Sign Out");
  }

  bool isLoggedIn = false;

  void onLoginStatusChanged(bool isLoggedIn) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
    });
  }

  void initiateFacebookLogin() async {
    fl.FacebookLogin facebookLogin = new fl.FacebookLogin();
    facebookLogin.loginBehavior = fl.FacebookLoginBehavior.webViewOnly;
    var facebookLoginResult = await facebookLogin.logIn(['email']);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Token Facebook Login : " + prefs.getString("fcmToken"));
    switch (facebookLoginResult.status) {
      case fl.FacebookLoginStatus.error:
        print("Error");
        onLoginStatusChanged(false);
        break;
      case fl.FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        onLoginStatusChanged(false);
        break;
      case fl.FacebookLoginStatus.loggedIn:
        prefs.setString("facebookToken", facebookLoginResult.accessToken.token);
        onLoginStatusChanged(true);
        var facebookProfile = await getFacebookProfile(
            facebookToken: facebookLoginResult.accessToken.token);
        if (facebookProfile != null) {
          print(facebookProfile);
          var userExist = await emailExist(email: facebookProfile["email"]);
          if (userExist) {
            showDialog(
                context: context,
                builder: (context) {
                  return new Dialog(
                    child: new Container(
                      color: PrimaryColor,
                      padding: EdgeInsets.all(10),
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                  child: new CircularProgressIndicator())),
                          new Text(
                            "Redirecting ...",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                });
            Navigator.of(context)
                .push(new MaterialPageRoute(builder: (context) => MainHome()));
          } else {
            prefs.setString("email", facebookProfile["email"]);
            prefs.setString("first_name", facebookProfile["first_name"]);
            prefs.setString("phone_number", facebookProfile["phone_number"]);
            // prefs.setString("android_id", facebookLoginResult.accessToken.token);
            prefs.setString("android_id", prefs.getString("fcmToken"));
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context) => SignUp(
                    name: facebookProfile["first_name"],
                    email: facebookProfile["email"],
                    phoneNumber: facebookProfile["phone_number"],
                    token: prefs.getString("fcmToken"))));
          }
        }
        break;
    }
  }

  Future<bool> doRegister(
      {String firstName, String lastName, String email, id}) async {
    http.Response rq =
        await http.post("https://www.bananaz.co/ios/register/", body: {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "password": "",
      "zip_code": "",
      "address": "",
      "city": "",
      "country": ""
    });
    var jsonData = jsonDecode(rq.body);
    if (jsonData["status"] == "1") {
      return true;
    }
    return false;
  }

  Future<bool> emailExist({email}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Token emailexist : " + prefs.getString("fcmToken"));
    print("Check Email Exist : " + email);
    http.Response data = await http.get(
        "https://www.bananaz.co/ios/customer2/?email=$email&android_id=" +
            prefs.getString("fcmToken"));
    var jsonData = jsonDecode(data.body);
    if (jsonData["email"] == "") {
      print("tidak ada");
      return false;
    } else {
      print("ada");
      print("Eksekusi");
      prefs.setString("id_customer", jsonData["id_customer"]);
      prefs.setString("first_name", jsonData["first_name"]);
      prefs.setString("last_name", jsonData["last_name"]);
      prefs.setString("email", jsonData["email"]);
      prefs.setString("phone_number", jsonData["phone_number"]);
      prefs.setString("address", jsonData["address"]);
      prefs.setString("city", jsonData["city"]);
      prefs.setString("zip_code", jsonData["zip_code"]);
      prefs.setString("country", jsonData["country"]);
      prefs.setString("android_id", prefs.getString("fcmToken"));
      prefs.setString("status", jsonData["status"]);
      return true;
    }
  }

  Future<dynamic> getFacebookProfile({String facebookToken}) async {
    http.Response data = await http.get(
        "https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$facebookToken");
    var jsonData = jsonDecode(data.body);
    return jsonData;
  }

  void initiateFacebookLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("facebookToken");
    fl.FacebookLogin _facebookLogin = fl.FacebookLogin();
    await _facebookLogin.logOut();
    await _auth.signOut();
  }

  _lupaPass() async {
    const url = 'https://www.bananaz.co/customer/forgot';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  var _formKeyLogin = GlobalKey<FormState>();

  void _validateInputs() {
    if (_formKeyLogin.currentState.validate()) {
//    If all data are correct then save data to out variables
      setState(() {
        _validated = true;
      });
    }
  }

  var _validated = false;

  Future<bool> doLoginToken({email, password}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("TOken dologin : " + prefs.getString("fcmToken"));
    //print(fcmToken);
    http.Response loginList = await http.get(
        "https://www.bananaz.co/ios/login/?email=$email&password=$password&android_id=" +
            prefs.getString("fcmToken"));
    var jsonData = jsonDecode(loginList.body);
    String status = jsonData["status"];
    if (status == "1") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("session_status", true);
      prefs.setString("email", jsonData["email"]);
      prefs.setString("first_name", jsonData["first_name"]);
      prefs.setString("last_name", jsonData["last_name"]);
      prefs.setString("phone_number", jsonData["phone_number"]);
      prefs.setString("address", jsonData["address"]);
      prefs.setString("city", jsonData["city"]);
      prefs.setString("zip_code", jsonData["zip_code"]);
      prefs.setString("country", jsonData["country"]);
      prefs.setString("status", jsonData["status"]);
      prefs.setString("android_id", prefs.getString("fcmToken"));
      prefs.setString("id_customer", jsonData["id_customer"]);
      return true;
    } else {
      return false;
    }
  }

  /*Future<bool> doLogin({email, password}) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    http.Response userData = await http.get(
        "https://www.bananaz.co/ios/login/?email=$email&password=$password&android_id="+prefs.getString("fcmToken"));
    var jsonData = jsonDecode(userData.body);
    if (jsonData["status"] == "1") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("id_customer", jsonData["id_customer"]);
      prefs.setString("first_name", jsonData["first_name"]);
      return true;
    } else if (jsonData["status"] == "2") {
      return false;
    }
    return false;
  }*/

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  String _emptyValidation(value) {
    if (value == '') {
      return "this field is required";
    }
    return null;
  }

  String _emptyValidation2(value) {
    if (value == '') {
      return "this field is required";
    }

    if (value.length <= 4) {
      return "Password must be more than 4 characters";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: new Container(
          padding: EdgeInsets.all(15),
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              gradient: new LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [SecondaryColor, SecondaryColor])),
          child: new Center(
              child: new SingleChildScrollView(
            child: new Form(
              key: _formKeyLogin,
              child: new Column(
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.all(8),
                    child: new Image.asset(
                      "asset/img/bananaz_logo_apps.png",
                      width: 220,
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.all(8),
                    child: new Image.asset(
                      "asset/img/icon_bike2.png",
                      width: 180,
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: new TextFormField(
                      validator: _emptyValidation,
                      controller: _emailController,
                      autocorrect: false,
                      cursorColor: Colors.white,
                      cursorWidth: .9,
                      style: new TextStyle(
                          color: Colors.white, fontStyle: FontStyle.normal),
                      decoration: new InputDecoration(
                        prefixIcon: new Icon(
                          Icons.alternate_email,
                          color: Colors.white,
                        ),
                        labelText: "Email",
                        alignLabelWithHint: true,
                        labelStyle:
                            new TextStyle(fontSize: 13.8, color: Colors.white),
                        enabledBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                          color: Colors.white,
                          width: .5,
                        )),
                        border: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                          color: Colors.white,
                          width: .5,
                        )),
                        focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                          color: Colors.white,
                          width: .5,
                        )),
                      ),
                    ),
                  ),
                  new Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(8),
                    child: new TextFormField(
                      validator: _emptyValidation2,
                      controller: _passwordController,
                      obscureText: true,
                      autocorrect: false,
                      cursorColor: Colors.white,
                      cursorWidth: .9,
                      style: new TextStyle(
                          color: Colors.white, fontStyle: FontStyle.normal),
                      decoration: new InputDecoration(
                        prefixIcon: new Icon(
                          Icons.vpn_key,
                          color: Colors.white,
                        ),
                        labelText: "Password",
                        alignLabelWithHint: true,
                        labelStyle:
                            new TextStyle(fontSize: 13.8, color: Colors.white),
                        enabledBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                          color: Colors.white,
                          width: .5,
                        )),
                        border: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                          color: Colors.white,
                          width: .5,
                        )),
                        focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                          color: Colors.white,
                          width: .5,
                        )),
                      ),
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.all(8),
                    alignment: Alignment.centerRight,
                    child: new GestureDetector(
                      onTap: () async {
                        await _lupaPass();
                      },
                      child: new Text(
                        "Forgot the password ?",
                        style: new TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  new SizedBox(
                    height: 10,
                  ),
                  new Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: new SizedBox(
                      width: double.infinity,
                      child: new FlatButton(
                        splashColor: Colors.white,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(25)),
                        color: PrimaryColor,
                        child: new Text(
                          "LOGIN",
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          _validateInputs();
                          if (_validated) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return new Dialog(
                                    backgroundColor: PrimaryColor,
                                    child: Container(
                                      padding: new EdgeInsets.all(5),
                                      child: new ListView(
                                        shrinkWrap: true,
                                        children: <Widget>[
                                          new Container(
                                              padding: new EdgeInsets.all(8),
                                              child: Center(
                                                  child:
                                                      new CircularProgressIndicator(
                                                valueColor:
                                                    new AlwaysStoppedAnimation<
                                                        Color>(Colors.black),
                                              ))),
                                          new Container(
                                              padding: new EdgeInsets.all(8),
                                              child: Center(
                                                  child: new Text(
                                                "Loading ...",
                                                style: new TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ))),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                            var loginStatus = await doLoginToken(
                                email: _emailController.text,
                                password: _passwordController.text);
                            Navigator.pop(context);
                            if (loginStatus) {
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (context) => new MainHome()));
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return new Dialog(
                                      backgroundColor: PrimaryColor,
                                      child: Container(
                                        padding: new EdgeInsets.all(15),
                                        child: new Text(
                                          "Login Failed",
                                          textAlign: TextAlign.center,
                                          style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.all(9),
                    child: new GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (context) => SignUp()));
                      },
                      child: new Text(
                        "Doesn't have any account ?",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.all(15),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new SizedBox(
                          width: 75,
                          height: 1,
                          child: new Container(
                            color: Colors.white,
                          ),
                        ),
                        new Text(
                          "OR",
                          style: new TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        new SizedBox(
                          width: 75,
                          height: 1,
                          child: new Container(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new RaisedButton.icon(
                          icon: new Image.asset(
                            "asset/img/google_icon.png",
                            width: 12,
                          ),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20)),
                          label: new Text("Login with google"),
                          onPressed: () {
                            signInWithGoogle();
                          },
                          color: Colors.white,
                          elevation: .4,
                        ),
                        new RaisedButton.icon(
                          splashColor: Colors.white,
                          icon: new Image.asset(
                            "asset/img/facebook_icon.png",
                            width: 12,
                          ),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20)),
                          label: new Text(
                            "Login with facebook",
                            style: new TextStyle(color: Colors.white),
                          ),
                          onPressed: () => initiateFacebookLogin(),
                          color: Colors.blue,
                          elevation: .4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}

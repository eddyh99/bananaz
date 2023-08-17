import 'dart:async';
import 'dart:io';

import 'package:devbananaz/app2_book.dart';
import 'package:devbananaz/fcm.dart';
import 'package:devbananaz/main_home.dart';
import 'package:devbananaz/on_going_promo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'package:devbananaz/login.dart';

const SecondaryColor = Color(0xff62BBF9);
const PrimaryColor2 = Color(0xffFFC300);

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = new FirebaseMessaging();

  StreamSubscription iosSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //FcmHelper.config(context);
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
      });
      //_fcm.requestNotificationPermissions(IosNotificationSettings());
      _fcm.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true));
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }

    _fcm.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print("on MessageLaunch : $message");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (message['action_destination'] == "MyBookingResultActivity") {
          prefs.setString("notifbooking", message['id'].toString());
        } else if (message['action_destination'] == "PromoActivity") {
          prefs.setString("notifpromo", message['id'].toString());
        }
      },
    );
  }

  _saveDeviceToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //String uid = prefs.getString("uid");

    String fcmToken = await _fcm.getToken();
    prefs.setString("fcmToken", fcmToken);
    //print("Token Main Dart : "+fcmToken);

//    if(fcmToken != null){
//      var tokenRef=_db
//          .collection("users")
//          .document(fcmToken)
//          .collection("tokens")
//          .document("fcmToken");
//
//      await tokenRef.setData({
//        "token":fcmToken,
//        "created at":FieldValue.serverTimestamp(),
//        "platform":Platform.operatingSystem
//      });
//    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
          fontFamily: "avenir",
          appBarTheme: new AppBarTheme(
              color: SecondaryColor,
              iconTheme: new IconThemeData(
                color: SecondaryColor,
              ),
              textTheme:
                  new TextTheme(headline4: new TextStyle(fontFamily: "avenir")),
              elevation: 0)),
      debugShowCheckedModeBanner: false,
      home: new Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<void> nextPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id_customer = prefs.getString("id_customer");
    await Future.delayed(Duration(seconds: 3));
    if (id_customer == null) {
      Navigator.of(context)
          .push(new MaterialPageRoute(builder: (context) => Login()));
    } else {
      emailExist();
      Navigator.of(context)
          .push(new MaterialPageRoute(builder: (context) => MainHome()));
    }
  }

  @override
  void initState() {
    nextPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: SecondaryColor,
        title: new Image.asset(
          "asset/img/bananaz_logo_apps.png",
          width: 229,
        ),
        centerTitle: true,
      ),
      body: new Container(
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            SecondaryColor,
            SecondaryColor,
          ],
        )),
        child: new Center(
          child: new SingleChildScrollView(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Container(
                    padding: new EdgeInsets.all(25),
                    child: new Image.asset(
                      "asset/img/text_1.png",
                      width: 250,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//UPDATE TOKEN ENDPOINT
void emailExist() async {
  final FirebaseMessaging _fcm = new FirebaseMessaging();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String email = prefs.getString("email");
  String fcmToken = await _fcm.getToken();
  prefs.setString("fcmToken", fcmToken);
  print("Token Main Dart Update Endpoint : " + fcmToken);
  print("Check Email : " + email);
  http.Response data = await http.get(
      "https://www.bananaz.co/ios/customer2/?email=" +
          email +
          "&android_id=" +
          fcmToken);
  //var jsonData = jsonDecode(data.body);
  //if (jsonData["email"] == "") {
  //  return false;
  //}
}

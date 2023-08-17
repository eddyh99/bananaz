import 'dart:async';
import 'dart:io';

import 'package:devbananaz/app2_book.dart';
import 'package:devbananaz/main_home.dart';
import 'package:devbananaz/on_going_promo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:devbananaz/login.dart';


void main()=>runApp(MyApp());

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
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
      });
      //_fcm.requestNotificationPermissions(IosNotificationSettings());
      _fcm.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true)
      );
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }else{
      _saveDeviceToken();
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("Message Message : $message");
        if(message["action_destination"]=="MyBookingResultActivity"){

          showDialog(
              context: context,
              builder: (BuildContext context) {
                return new AlertDialog(
                  backgroundColor: Colors.orangeAccent,
                  title: new Text(message["title"]),
                  content: new Text(message["message"]),
                  actions: <Widget>[
                    new FlatButton(
                      color: Colors.orangeAccent,
                      textColor: Colors.white,
                      child: new Text("More Detail"),
                      onPressed: () =>
                          Navigator.of(context).push(new MaterialPageRoute(
                              builder: (context) =>
                                  DetailBook(id: message["id"],)
                          )),
                    ),
                    new FlatButton(
                      color: Colors.orangeAccent,
                      textColor: Colors.white,
                      child: new Text("Close"),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                );
              });



        } else if(message["action_destination"]=="HomeActivity"){
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return new AlertDialog(
                  backgroundColor: Colors.orangeAccent,
                  title: new Text(message["title"]),
                  content: new Text(message["message"]),
                  actions: <Widget>[
                    new FlatButton(
                      color: Colors.orangeAccent,
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
                  backgroundColor: Colors.orangeAccent,
                  title: new Text(message["title"]),
                  content: new Text(message["message"]),
                  actions: <Widget>[
                    new FlatButton(
                      color: Colors.orangeAccent,
                      textColor: Colors.white,
                      child: new Text("More Detail"),
                      onPressed: () =>
                          Navigator.of(context).push(new MaterialPageRoute(
                              builder: (context) =>
                                  OnGoingPromoPush(idPromotion: message["id"],)
                          )),
                    ),
                    new FlatButton(
                      color: Colors.orangeAccent,
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
                  backgroundColor: Colors.orangeAccent,
                  title: new Text(message["title"]),
                  content: new Text(message["message"]),
                  actions: <Widget>[
                    new FlatButton(
                      color: Colors.orangeAccent,
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
        if(message["action_destination"]=="MyBookingResultActivity"){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>DetailBook(id: message["id"],)
          ));
        } else if(message["action_destination"]=="HomeActivity"){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>MainHome()
          ));
        } else if(message["action_destination"]=="PromoActivity"){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>OnGoingPromoPush(idPromotion: message["id"],)
          ));
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("on Message2 : $message");

          if (message["action_destination"] == "MyBookingResultActivity") {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context) => DetailBook(id: message["id"],)
            ));
          } else if (message["action_destination"] == "HomeActivity") {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context) => MainHome()
            ));
          } else if (message["action_destination"] == "PromoActivity") {

              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (context) =>
                      OnGoingPromoPush(idPromotion: message["id"],)
              ));

          }

      },
    );
  }

  _saveDeviceToken()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    //String uid = prefs.getString("uid");

    String fcmToken=await _fcm.getToken();
    prefs.setString("fcmToken", fcmToken);
    print("Token Main Dart : "+fcmToken);

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
      theme:new ThemeData(
        fontFamily: "avenir",
        appBarTheme: new AppBarTheme(
          color: Colors.lightBlueAccent,
          iconTheme: new IconThemeData(
            color: Colors.lightBlueAccent,
          ),
          textTheme: new TextTheme(
            display1: new TextStyle(
              fontFamily: "avenir"
            )
          ),
          elevation: 0
        )
      ),
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

    Future<void> nextPage()async{
      SharedPreferences prefs=await SharedPreferences.getInstance();
      var id_customer=prefs.getString("id_customer");
      await Future.delayed(Duration(seconds: 3));
      if(id_customer == null) {
        Navigator.of(context).push(
            new MaterialPageRoute(builder: (context) => Login())
        );
      } else {
          emailExist();
          Navigator.of(context).push(
              new MaterialPageRoute(builder: (context) => MainHome())
          );


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
        backgroundColor: Colors.lightBlueAccent,
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
              Colors.lightBlue,
              Colors.lightBlueAccent,
            ],
          )
        ),
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
                    )
                ),
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
  SharedPreferences prefs=await SharedPreferences.getInstance();
  String email=prefs.getString("email");
  String fcmToken=await _fcm.getToken();
  prefs.setString("fcmToken", fcmToken);
  print("Token Main Dart Update Endpoint : "+fcmToken);
  print("Check Email : "+ email);
  http.Response data = await http.get("https://dev.bananaz.co/ios/customer2/?email="+email+"&android_id="+fcmToken);
  //var jsonData = jsonDecode(data.body);
  //if (jsonData["email"] == "") {
  //  return false;
  //}
}
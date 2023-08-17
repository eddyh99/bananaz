import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:devbananaz/on_going_promo.dart';
import 'package:devbananaz/app2_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:webview_flutter/webview_flutter.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_swiper/flutter_swiper.dart';


class FcmHelper {

   static goto(String id, String message, String activity, BuildContext context) async{

    const SecondaryColor =  Color(0xff62BBF9);
    const PrimaryColor2 =  Color(0xffFFC300);

    SharedPreferences prefs=await SharedPreferences.getInstance();
    String isi= activity+id+message;
    bool cek = prefs.getBool(isi);

    if(!cek) {
      prefs.setBool(isi, true);
      print("on MessageLaunch : $message");
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIos: 10,
          backgroundColor: PrimaryColor2,
          textColor: Colors.black,
          fontSize: 13.0
      );

      if (activity == "MyBookingResultActivity") {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) => DetailBook(id: id,)
        ));
      } else if (activity == "PromoActivity") {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) =>
            new OnGoingPromoPush(
              idPromotion: id,)));
      }
    }
  }


   static config(BuildContext context){
    const SecondaryColor =  Color(0xff62BBF9);
    const PrimaryColor2 =  Color(0xffFFC300);
    StreamSubscription iosSubscription;
    final FirebaseMessaging _fcm = new FirebaseMessaging();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {

      });

      _fcm.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true)
      );
      _fcm.requestNotificationPermissions(IosNotificationSettings());

      _fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("Message MessageonMessage apphome : $message");
          if(message["action_destination"]=="MyBookingResultActivity"){

            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    backgroundColor: PrimaryColor2,
                    title: new Text(message["title"]),
                    content: new Text(message["message"]),
                    actions: <Widget>[
                      new FlatButton(
                        color: PrimaryColor2,
                        textColor: Colors.white,
                        child: new Text("More Detail"),
                        onPressed: () =>
                            Navigator.of(context).push(new MaterialPageRoute(
                                builder: (context) =>
                                    DetailBook(id: message["id"],)
                            )),
                      ),
                      new FlatButton(
                        color: PrimaryColor2,
                        textColor: Colors.white,
                        child: new Text("Close"),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  );
                });



          } else if(message["action_destination"]=="HomeActivity"){
            Fluttertoast.showToast(
                msg: message["message"],
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIos: 10,
                backgroundColor: PrimaryColor2,
                textColor: Colors.black,
                fontSize: 13.0
            );
            /*showDialog(
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
              });*/

          }else if(message["action_destination"]=="BookingActivity"){
            print("notif payment berhasil");
            Fluttertoast.showToast(
                msg: message["message"],
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIos: 10,
                backgroundColor: PrimaryColor2,
                textColor: Colors.black,
                fontSize: 13.0
            );

          } else if(message["action_destination"]=="PromoActivity"){
            showDialog(
                context: context,
                builder: (BuildContext context)
                {
                  return new AlertDialog(
                    backgroundColor: PrimaryColor2,
                    title: new Text(message["title"]),
                    content: new Text(message["message"]),
                    actions: <Widget>[
                      new FlatButton(
                        color: PrimaryColor2,
                        textColor: Colors.white,
                        child: new Text("More Detail"),
                        onPressed: () =>
                            Navigator.of(context).push(new MaterialPageRoute(
                                builder: (context) =>
                                    OnGoingPromoPush(
                                        idPromotion: message
                                        ["id"]
                                    )
                            )),
                      ),
                      new FlatButton(
                        color: PrimaryColor2,
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
                    backgroundColor: PrimaryColor2,
                    title: new Text(message["title"]),
                    content: new Text(message["message"]),
                    actions: <Widget>[
                      new FlatButton(
                        color: PrimaryColor2,
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
          print("on MessageonResume apphome : $message");
          if(message["action_destination"]=="MyBookingResultActivity"){
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context)=>DetailBook(id: message["id"],)
            ));

          } else if(message["action_destination"]=="HomeActivity"){
            /*Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>MainHome()
          ));*/
            Fluttertoast.showToast(
                msg: message["message"],
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIos: 10,
                backgroundColor: PrimaryColor2,
                textColor: Colors.black,
                fontSize: 13.0
            );
          } else if(message["action_destination"]=="PromoActivity"){
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context)=>OnGoingPromoPush(
                  idPromotion: message
                  ["id"],
                )
            ));

          }
        },
      );
    }
    _fcm.subscribeToTopic('bananaz');
    String fcmToken= _fcm.getToken().toString();
    return fcmToken;
  }
}
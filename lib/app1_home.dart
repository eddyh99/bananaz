import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:devbananaz/fcm.dart' as prefix0;
import 'package:devbananaz/on_going_promo.dart';
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
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'main_home.dart';
import 'app2_book.dart';
import 'login.dart';

const PrimaryColor = Color(0xffFFC300);
const SecondaryColor = Color(0xff62BBF9);

class AppPage1Provider {
  List pickupDataSuggestionPlace;
  List returnDataSuggestionPlace;
  List dataPromo;
  List dataFeed;

  Future<void> getDataPromo() async {
    http.Response data = await http.get("https://www.bananaz.co/ios/promo/");
    var jsonData = jsonDecode(data.body);
    dataPromo = jsonData;
  }

  Future<void> getFeedData() async {
    http.Response data = await http.get("https://www.bananaz.co/ios/feed/");
    var jsonData = jsonDecode(data.body);
    dataFeed = jsonData;
  }

  Future<void> getSuggestionPlaceData({input, type}) async {
    http.Response data = await http.get(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=establishment&location=-8.409518,115.188919&radius=500&key=AIzaSyAG8aO32wyJSU2grifmQOL2IF8LvvtClWI");
    var jsonData = jsonDecode(data.body);
    if (type == 'pickup') {
      pickupDataSuggestionPlace = jsonData["predictions"];
    } else if (type == 'return') {
      returnDataSuggestionPlace = jsonData["predictions"];
    }
  }
}

class AppPage1Bloc {
  AppPage1Provider _appPage1Provider = new AppPage1Provider();

  StreamController _appPage1Controller = new StreamController.broadcast();
  StreamController _appPage1ControllerFeed = new StreamController.broadcast();
  StreamController _appPage1ControllerSuggestion =
      new StreamController.broadcast();

  Stream get _appPage1Streamer => _appPage1Controller.stream;
  Stream get _appPage1StreamerFeed => _appPage1ControllerFeed.stream;
  Stream get _appPage1StreamerSuggestion =>
      _appPage1ControllerSuggestion.stream;

  void dispose() {
    _appPage1Controller.close();
    _appPage1ControllerFeed.close();
    _appPage1ControllerSuggestion.close();
  }

  Future<void> getSuggestionPlaceBloc({input, type}) async {
    await _appPage1Provider.getSuggestionPlaceData(input: input, type: type);
    if (type == 'pickup') {
      _appPage1ControllerSuggestion.sink
          .add(_appPage1Provider.pickupDataSuggestionPlace);
    } else if (type == 'return') {
      _appPage1ControllerSuggestion.sink
          .add(_appPage1Provider.returnDataSuggestionPlace);
    }
  }

  Future<void> getDataPromoBloc() async {
    await _appPage1Provider.getDataPromo();
    _appPage1Controller.sink.add(_appPage1Provider.dataPromo);
  }

  Future<void> getDataFeedBloc() async {
    await _appPage1Provider.getFeedData();
    _appPage1ControllerFeed.sink.add(_appPage1Provider.dataFeed);
  }
}

class AppPage1 extends StatefulWidget {
  final AppPage1Provider _appPage1Provider = new AppPage1Provider();
  final AppPage1Bloc _appPage1Bloc = new AppPage1Bloc();

  final bool onLaunchStatus;

  AppPage1({this.onLaunchStatus});

  @override
  _AppPage1State createState() => _AppPage1State();
}

class _AppPage1State extends State<AppPage1> {
  DateTime datePick;
  DateTime dateReturn;
  TimeOfDay timePick;
  TimeOfDay timeReturn;
  //final Firestore _db = Firestore.instance;
  //final FirebaseMessaging _fcm = new FirebaseMessaging();

  _openFeed({urlTarget}) async {
    var url = urlTarget;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> getDate({String type}) async {
    if (type == "pickup") {
      final dateResult = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        initialDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 90)),
      );
      setState(() {
        datePick = dateResult;
      });
    } else if (type == "return") {
      //print(datePick.day);
      final dateResult = await showDatePicker(
        context: context,
        firstDate: DateTime(datePick.year, datePick.month, datePick.day + 1),
        initialDate: datePick == null
            ? DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 1)
            : DateTime(datePick.year, datePick.month, datePick.day + 1),
        lastDate: DateTime.now().add(Duration(days: 90)),
      );
      setState(() {
        dateReturn = dateResult;
      });
    }
  }

  Future<void> getTime(String type) async {
    final timeResult = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 09, minute: 00));
    if (type == "pickup") {
      setState(() {
        timePick = timeResult;
      });
    } else if (type == "return") {
      setState(() {
        timeReturn = timeResult;
      });
    }
  }

  Future<String> getCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("id_customer");
    return id;
  }

  void cek() async {
    final FirebaseMessaging _fcm = new FirebaseMessaging();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //
    String notifpromo = prefs.getString("notifpromo");
    String notifbooking = prefs.getString("notifbooking");

    if (notifpromo != null) {
      prefs.setString("notifpromo", null);
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (context) => new OnGoingPromoPush(
                idPromotion: notifpromo,
              )));
    }

    if (notifbooking != null) {
      prefs.setString("notifbooking", null);
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (context) => DetailBook(
                id: notifbooking,
              )));
    }
    //

    String email = prefs.getString("email");
    String fcmToken = await _fcm.getToken();
    print("Check Double Login : " + email);
    http.Response data =
        await http.get("https://www.bananaz.co/ios/customer/?email=" + email);
    var jsonData = jsonDecode(data.body);
    if (jsonData["android_id"] != fcmToken) {
      Fluttertoast.showToast(
          msg: "You are already logged in on a different device.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 10,
          backgroundColor: PrimaryColor,
          textColor: Colors.black,
          fontSize: 13.0);
      prefs.remove("user_id");
      prefs.remove("id_customer");
      _fcm.unsubscribeFromTopic("bananaz");
      initiateFacebookLogout();
      signOutGoogle();

      Navigator.of(context)
          .push(new MaterialPageRoute(builder: (context) => Login()));
    }
  }

  List destinationMenu = ["bali", "More locations coming soon!"];

  @override
  void initState() {
    this.widget._appPage1Bloc.getDataPromoBloc();
    this.widget._appPage1Bloc.getDataFeedBloc();
    super.initState();

    //FcmHelper.config(context);

    /*if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
      });
     // _fcm.requestNotificationPermissions(IosNotificationSettings());
      _fcm.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true)
      );
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("Message MessageonMessage apphome : $message");
        if(message["action_destination"]=="MyBookingResultActivity"){

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
                      child: new Text("More Detail"),
                      onPressed: () =>
                          Navigator.of(context).push(new MaterialPageRoute(
                              builder: (context) =>
                                  DetailBook(id: message["id"],)
                          )),
                    ),
                    new FlatButton(
                      color: PrimaryColor,
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
              backgroundColor: PrimaryColor,
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
              backgroundColor: PrimaryColor,
              textColor: Colors.black,
              fontSize: 13.0
          );

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
              backgroundColor: PrimaryColor,
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
      onLaunch: (Map<String, dynamic> message) async {

        print("on MessageonLaunch apphome : $message");
        SharedPreferences prefs=await SharedPreferences.getInstance();
        var promoPush=prefs.getString("promoPush");
        //Navigator.of(context).push(new MaterialPageRoute(
        //    builder: (context)=>MainHome()
        //));
          /*
          if (message["action_destination"] == "MyBookingResultActivity") {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context) => DetailBook(id: message["id"],)
            ));
          } else if (message["action_destination"] == "HomeActivity") {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context) => MainHome()
            ));
          } else if (message["action_destination"] == "PromoActivity") {
            //if(this.widget.onLaunchStatus == null){
              Navigator.of(context).push(new MaterialPageRoute(builder: (context)=>OnGoingPromoPush(idPromotion: message["id"],)));
            //}else{
            //  print("Done");
            //}
          }*/


      },
    );
    _fcm.subscribeToTopic('bananaz2');
    */

    cek(); //doublelogin
  }

  String dropdownValue = "Bali - Scooter or motorbike";

  TextEditingController _pickupLocationController = new TextEditingController();
  TextEditingController _returnLocationController = new TextEditingController();

  Future<bool> checkOrder(
      {pickupLocation,
      pickupDate,
      pickupTime,
      returnLocation,
      returnDate,
      returnTime}) async {
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();
    http.Response data = await http.get(
        "https://www.bananaz.co/ios/cekreservasi2/?timezon=$currentTimeZone&pick_up_date=$pickupDate&return_date=$returnDate&pick_up_location=$pickupLocation&return_location=$returnLocation&pick_up_time=$pickupTime&return_time=$returnTime");
    print(jsonDecode(data.body));
    var jsonDatas = jsonDecode(data.body);

    if (jsonDatas["status"] == "1") {
      print("true " + jsonDatas["status"]);
      return true;
    } else {
      print("false " + jsonDatas["status"]);
      return false;
    }
  }

  var _key = GlobalKey<FormState>();
  bool _validated = false;
  void _validateInputs() {
    if (_key.currentState.validate()) {
//    If all data are correct then save data to out variables
      setState(() {
        _validated = true;
      });
    }
  }

  _saveDeviceToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //String uid = prefs.getString("uid");

    //String fcmToken = await _fcm.getToken();
    //prefs.setString("fcmToken", fcmToken);

//    if (fcmToken != null) {
//      var tokenRef = _db
//          .collection("users")
//          .document(uid)
//          .collection("tokens")
//          .document("fcmToken");
//
//      await tokenRef.setData({
//        "token": fcmToken,
//        "created at": FieldValue.serverTimestamp(),
//        "platform": Platform.operatingSystem
//      });
//    }
  }

  //FocusNode _focus=new FocusNode();

  void _onPickupFocus() {
    showDialog(
        context: context,
        builder: (context) {
          return new Container(
            padding: new EdgeInsets.all(9),
            child: new Material(
              child: new SingleChildScrollView(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Container(
                      width: double.infinity,
                      child: new FlatButton(
                        child: new Text(
                          "Close",
                          style: new TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    new TextFormField(
                      autofocus: true,
                      validator: (value) {
                        if (value == "") {
                          return "Pickup location cannot be empty";
                        }
                        return null;
                      },
                      controller: _pickupLocationController,
                      onChanged: (value) {
                        this.widget._appPage1Bloc.getSuggestionPlaceBloc(
                            input: value, type: "pickup");
                      },
                      autocorrect: false,
                      cursorColor: SecondaryColor,
                      cursorWidth: .9,
                      style: new TextStyle(
                          color: Colors.black, fontStyle: FontStyle.normal),
                      decoration: new InputDecoration(
                        prefixIcon: new Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                        ),
                        suffixIcon: new IconButton(
                            icon: new Icon(Icons.cancel),
                            onPressed: () {
                              setState(() {
                                _pickupLocationController.text = "";
                              });
                            }),
                        labelText: "Pick up Location",
                        alignLabelWithHint: true,
                        labelStyle: new TextStyle(fontSize: 13.8),
                        enabledBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                          color: SecondaryColor,
                          width: .5,
                        )),
                        border: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                          color: SecondaryColor,
                          width: .5,
                        )),
                        focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                          color: SecondaryColor,
                          width: .5,
                        )),
                      ),
                    ),
                    new StreamBuilder(
                      stream:
                          this.widget._appPage1Bloc._appPage1StreamerSuggestion,
                      initialData: this
                          .widget
                          ._appPage1Provider
                          .pickupDataSuggestionPlace,
                      builder: (context, snapshot) {
                        if (snapshot.data == null ||
                            snapshot.data.length == 0) {
                          return Container();
                        } else {
                          return Container(
                            height: 800,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, i) {
                                return new ListTile(
                                  title:
                                      new Text(snapshot.data[i]["description"]),
                                  onTap: () {
                                    _pickupLocationController.text =
                                        snapshot.data[i]["description"];
                                    this
                                        .widget
                                        ._appPage1Bloc
                                        .getSuggestionPlaceBloc(
                                            input: "", type: "pickup");
                                    Navigator.pop(context);
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _onReturnFocus() {
    showDialog(
        context: context,
        builder: (context) {
          return new Container(
            padding: new EdgeInsets.all(9),
            child: new Material(
              child: new SingleChildScrollView(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Container(
                      width: double.infinity,
                      child: new FlatButton(
                        child: new Text(
                          "Close",
                          style: new TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    new TextFormField(
                      autofocus: true,
                      validator: (value) {
                        if (value == "") {
                          return "Return location cannot be empty";
                        }
                        return null;
                      },
                      controller: _returnLocationController,
                      onChanged: (value) {
                        this.widget._appPage1Bloc.getSuggestionPlaceBloc(
                            input: value, type: "return");
                      },
                      autocorrect: false,
                      cursorColor: SecondaryColor,
                      cursorWidth: .9,
                      style: new TextStyle(
                          color: Colors.black, fontStyle: FontStyle.normal),
                      decoration: new InputDecoration(
                        prefixIcon: new Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                        ),
                        suffixIcon: new IconButton(
                            icon: new Icon(Icons.cancel),
                            onPressed: () {
                              setState(() {
                                _returnLocationController.text = "";
                              });
                            }),
                        labelText: "Return Location",
                        alignLabelWithHint: true,
                        labelStyle: new TextStyle(fontSize: 13.8),
                        enabledBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                          color: SecondaryColor,
                          width: .5,
                        )),
                        border: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                          color: SecondaryColor,
                          width: .5,
                        )),
                        focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                          color: SecondaryColor,
                          width: .5,
                        )),
                      ),
                    ),
                    new StreamBuilder(
                      stream:
                          this.widget._appPage1Bloc._appPage1StreamerSuggestion,
                      initialData: this
                          .widget
                          ._appPage1Provider
                          .pickupDataSuggestionPlace,
                      builder: (context, snapshot) {
                        if (snapshot.data == null ||
                            snapshot.data.length == 0) {
                          return Container();
                        } else {
                          return Container(
                            height: 800,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, i) {
                                return new ListTile(
                                  title:
                                      new Text(snapshot.data[i]["description"]),
                                  onTap: () {
                                    _returnLocationController.text =
                                        snapshot.data[i]["description"];
                                    this
                                        .widget
                                        ._appPage1Bloc
                                        .getSuggestionPlaceBloc(
                                            input: "", type: "return");
                                    Navigator.pop(context);
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      body: new ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: <Widget>[
          new Container(
            width: double.infinity,
            height: 35,
            color: SecondaryColor,
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 12.5, right: 12.8, left: 12.8, bottom: 7),
            child: new Card(
              elevation: .5,
              child: new Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                transform: Matrix4.translationValues(0, -35, 50),
                width: double.infinity,
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.circular(3),
                    color: Colors.white),
                child: Form(
                  key: _key,
                  child: new ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
//                  DESTINATION TEXTFORM FIELD
                      Container(
                        padding: EdgeInsets.all(8),
                        child: DropdownButtonFormField<String>(
                          decoration: new InputDecoration(
                            labelText: "Choose destination",
                            prefixIcon: new Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            border: new UnderlineInputBorder(
                                borderSide: new BorderSide(
                                    width: .8, color: SecondaryColor)),
                            enabledBorder: new UnderlineInputBorder(
                                borderSide: new BorderSide(
                                    width: .8, color: SecondaryColor)),
                          ),
                          value: dropdownValue,
                          onChanged: (String newValue) {},
                          items: <String>[
                            'Bali - Scooter or motorbike',
                            'More locations coming soon!',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

//                  DATE FIELD
                      new IntrinsicHeight(
                          child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                            new IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  new Icon(
                                    Icons.date_range,
                                    color: Colors.redAccent,
                                  ),
                                  new FlatButton(
                                    child: new Text(this.datePick == null
                                        ? "Pickup Date"
                                        : "${this.datePick.day}-${this.datePick.month}-${this.datePick.year}"),
                                    textColor: Colors.white,
                                    onPressed: () =>
                                        this.getDate(type: "pickup"),
                                    color: SecondaryColor,
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(3)),
                                  ),
                                ],
                              ),
                            ),

//                            TIME FIELD
                            new IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  new Icon(
                                    Icons.access_time,
                                    color: Colors.redAccent,
                                  ),
                                  new FlatButton(
                                    textColor: Colors.white,
                                    child: new Text(this.timePick == null
                                        ? "Pickup Time"
                                        : "${this.timePick.hour}:${this.timePick.minute}"),
                                    onPressed: () {
                                      getTime("pickup");
                                    },
                                    color: SecondaryColor,
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(3)),
                                  ),
                                ],
                              ),
                            ),
                          ])),
                      new Container(
                          decoration: new BoxDecoration(
                              border: new Border.all(
                                  width: 1, color: SecondaryColor),
                              borderRadius: new BorderRadius.circular(4)),
                          margin: EdgeInsets.only(bottom: 8, top: 8),
                          child: new FlatButton(
                            onPressed: () {
                              _onPickupFocus();
                            },
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                ),
                                new Expanded(
                                    child: new Text(
                                  _pickupLocationController.text == ""
                                      ? "Pickup Location"
                                      : _pickupLocationController.text,
                                  textAlign: TextAlign.center,
                                ))
                              ],
                            ),
                          )),

                      new IntrinsicHeight(
                          child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                            new IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  new Icon(
                                    Icons.date_range,
                                    color: Colors.redAccent,
                                  ),
                                  new FlatButton(
                                    child: new Text(this.dateReturn == null
                                        ? "Return Date"
                                        : "${this.dateReturn.day}-${this.dateReturn.month}-${this.dateReturn.year}"),
                                    textColor: Colors.white,
                                    onPressed: () =>
                                        this.getDate(type: "return"),
                                    color: SecondaryColor,
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(3)),
                                  ),
                                ],
                              ),
                            ),

//                            TIME FIELD
                            new IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  new Icon(
                                    Icons.access_time,
                                    color: Colors.redAccent,
                                  ),
                                  new FlatButton(
                                    textColor: Colors.white,
                                    child: new Text(this.timeReturn == null
                                        ? "Return Time"
                                        : "${this.timeReturn.hour}:${this.timeReturn.minute}"),
                                    onPressed: () => getTime("return"),
                                    color: SecondaryColor,
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(3)),
                                  ),
                                ],
                              ),
                            ),
                          ])),

                      new Container(
                          decoration: new BoxDecoration(
                              border: new Border.all(
                                  width: 1, color: SecondaryColor),
                              borderRadius: new BorderRadius.circular(4)),
                          margin: EdgeInsets.only(bottom: 8, top: 8),
                          child: new FlatButton(
                            onPressed: () {
                              _onReturnFocus();
                            },
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                ),
                                new Expanded(
                                    child: new Text(
                                  _returnLocationController.text == ""
                                      ? "Return Location"
                                      : _returnLocationController.text,
                                  textAlign: TextAlign.center,
                                ))
                              ],
                            ),
                          )),

                      new SizedBox(
                        width: double.infinity,
                        child: new RaisedButton(
                          splashColor: Colors.white,
                          textColor: Colors.white,
                          color: SecondaryColor,
                          onPressed: () async {
                            if (timePick == null ||
                                datePick == null ||
                                timeReturn == null ||
                                dateReturn == null ||
                                _pickupLocationController.text == "" ||
                                _returnLocationController.text == "") {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Center(
                                        child: new Card(
                                      child: new Container(
                                        color: PrimaryColor,
                                        padding: EdgeInsets.all(10),
                                        child: new Text(
                                            "Please complete all field"),
                                      ),
                                    ));
                                  });
                            } else {
                              _validateInputs();
                              if (_validated) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    });
                                var id = await getCustomerId();

                                String returntimefinal;
                                String pickuptimefinal;
                                if (timeReturn.minute.toString() == "0") {
                                  returntimefinal = "00";
                                } else {
                                  returntimefinal =
                                      timeReturn.minute.toString();
                                }

                                if (timePick.minute.toString() == "0") {
                                  pickuptimefinal = "00";
                                } else {
                                  pickuptimefinal = timePick.minute.toString();
                                }

                                Navigator.pop(context);
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return new AlertDialog(
                                        backgroundColor: PrimaryColor,
                                        title: new Text(
                                          "Terms and Conditions",
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: new Text(
                                            "To make a reservation, make sure you have a driving licence. After You make a payment, we will ask for a photo proof of driving licence in accordance with our terms and conditions. *We can cancel the reservation if your driving licence is not valid"),
                                        actions: <Widget>[
                                          new FlatButton(
                                            child: new Text(
                                              "Yes",
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            textColor: Colors.white,
                                            color: Colors.transparent,
                                            onPressed: () async {
                                              var pickupdates =
                                                  "${datePick.year}/${datePick.month}/${datePick.day}";
                                              bool isavailable = await checkOrder(
                                                  pickupLocation:
                                                      _pickupLocationController
                                                          .text,
                                                  pickupDate: pickupdates,
                                                  pickupTime:
                                                      "${timePick.hour}:$pickuptimefinal",
                                                  returnLocation:
                                                      _returnLocationController
                                                          .text,
                                                  returnDate:
                                                      "${dateReturn.year}/${dateReturn.month}/${dateReturn.day}",
                                                  returnTime:
                                                      "${timeReturn.hour}:$returntimefinal");
                                              print(pickupdates);
                                              if (isavailable == true) {
                                                Navigator.pop(context);
                                                Navigator.of(context).push(
                                                    new MaterialPageRoute(
                                                        builder: (context) =>
                                                            BookWebView(
                                                              idCustomer: id,
                                                              pickupDate:
                                                                  "${datePick.year}/${datePick.month}/${datePick.day}",
                                                              pickupLocation:
                                                                  _pickupLocationController
                                                                      .text,
                                                              pickupTime:
                                                                  "${timePick.hour}:$pickuptimefinal",
                                                              returnDate:
                                                                  "${dateReturn.year}/${dateReturn.month}/${dateReturn.day}",
                                                              returnTime:
                                                                  "${timeReturn.hour}:$returntimefinal",
                                                              returnLocation:
                                                                  _returnLocationController
                                                                      .text,
                                                            )));
                                              } else {
                                                Navigator.pop(context);
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return new AlertDialog(
                                                        backgroundColor:
                                                            PrimaryColor,
                                                        title: new Text(
                                                            "Scooters Not Available on Selected Date"),
                                                        content: new Text(
                                                            "Our scooters are fully booked. \n Please choose another date & time.\n" +
                                                                "If you want to rent a scooter on the same day, please make sure to book at least 3 hours in advance.\n"),
                                                        actions: <Widget>[
                                                          new FlatButton(
                                                            color: PrimaryColor,
                                                            textColor:
                                                                Colors.white,
                                                            child: new Text(
                                                                "Close"),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                          )
                                                        ],
                                                      );
                                                    });
                                              }
                                            },
                                          ),
                                          new FlatButton(
                                            child: new Text(
                                              "No",
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            textColor: Colors.redAccent,
                                            color: Colors.transparent,
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              }
                            }
                          },
                          child: new Text("CHECK AVAILABILITY"),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(3)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          new Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            child: new Text(
              "Ongoing Promos",
              style: new TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),

//          Page View ON GOING PROMO

          new Container(
            height: 150,
            width: 150,
            child: new Center(
              child: new StreamBuilder(
                stream: this.widget._appPage1Bloc._appPage1Streamer,
                initialData: this.widget._appPage1Provider.dataPromo,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return new ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: PageController(
                        keepPage: true,
                        viewportFraction: .42,
                        initialPage: 0,
                      ),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, i) {
                        return new Container(
                          width: 150,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: new GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (context) => OnGoingPromo(
                                        idPromotion: snapshot.data[i]
                                            ["id_promotion"],
                                        isiPromotion: snapshot.data[i]
                                            ["isi_promotion"],
                                        judulPromotion: snapshot.data[i]
                                            ["judul_promotion"],
                                        image: snapshot.data[i]["gambar"],
                                        tanggalPost: snapshot.data[i]
                                            ["tanggal_post"],
                                      )));
                            },
                            child: new Hero(
                              tag: snapshot.data[i]["id_promotion"],
                              child: new Container(
                                decoration: new BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: new BorderRadius.circular(3),
                                    image: new DecorationImage(
                                        image: new NetworkImage(
                                            "https://www.bananaz.co/assets/upload/image/${snapshot.data[i]["gambar"]}"),
                                        fit: BoxFit.fill)),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),

          new Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            child: new Text(
              "The Latest from Bananaz",
              style: new TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),

//          Page View Latest FEED
          new Container(
            height: 150,
            width: 150,
            child: new Center(
              child: new StreamBuilder(
                stream: this.widget._appPage1Bloc._appPage1StreamerFeed,
                initialData: this.widget._appPage1Provider.dataFeed,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return CircularProgressIndicator();
                  } else {
                    return new ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: PageController(
                        keepPage: true,
                        viewportFraction: .42,
                        initialPage: 0,
                      ),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, i) {
                        return new Container(
                          width: 150,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: new GestureDetector(
                            onTap: () {
                              _openFeed(urlTarget: snapshot.data[i]["id_feed"]);
                            },
                            child: new Container(
                              decoration: new BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: new BorderRadius.circular(3),
                                  image: new DecorationImage(
                                      image: new NetworkImage(
                                          "${snapshot.data[i]["gambar"]}"),
                                      fit: BoxFit.fill)),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookWebView extends StatefulWidget {
  final String pickupDate;
  final String pickupTime;
  final String pickupLocation;
  final String returnDate;
  final String returnTime;
  final String returnLocation;
  final String idCustomer;
  final FlutterWebviewPlugin plugin = new FlutterWebviewPlugin();

  BookWebView(
      {this.pickupDate,
      this.pickupTime,
      this.pickupLocation,
      this.returnDate,
      this.returnTime,
      this.returnLocation,
      this.idCustomer});

  @override
  _BookWebViewState createState() => _BookWebViewState();
}

class _BookWebViewState extends State<BookWebView> {
  String loadurls, titleloading;

  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();

    print("https://www.bananaz.co/ios/reservasi/?&pick_up_date=" +
        this.widget.pickupDate +
        "&pick_up_time=" +
        this.widget.pickupTime +
        "&pick_up_location=" +
        this.widget.pickupLocation +
        "&return_date=" +
        this.widget.returnDate +
        "&return_time=" +
        this.widget.returnTime +
        "&return_location=" +
        this.widget.returnLocation +
        "&id_customer=" +
        this.widget.idCustomer);
    String pickuplocation = Uri.encodeComponent(this.widget.pickupLocation);
    String returnlocation = Uri.encodeComponent(this.widget.returnLocation);
    loadurls = "https://www.bananaz.co/ios/reservasi/?pick_up_date=" +
        this.widget.pickupDate +
        "&pick_up_time=" +
        this.widget.pickupTime +
        "&pick_up_location=" +
        pickuplocation +
        "&return_date=" +
        this.widget.returnDate +
        "&return_time=" +
        this.widget.returnTime +
        "&return_location=" +
        returnlocation +
        "&id_customer=" +
        this.widget.idCustomer;

    String skrg =
        flutterWebviewPlugin.evalJavascript('location.href').toString();
    String urls;
    print(skrg);
    titleloading = "Preparing to Step 1 - Choose Bike";
    bool ispaypal = false;
    bool loadkah = false;

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      urls = url;
      print("load : " + urls);

      loadkah = false;
      if (urls.contains("reservasi")) {
        flutterWebviewPlugin.hide();
        loadkah = true;
        titleloading = "Preparing to Step 1 - Choose Bike";
      } else if (urls.contains("reservation")) {
        flutterWebviewPlugin.hide();
        loadkah = true;
        titleloading = "Preparing to Step 2 - Information";
      } else if (urls.contains("features")) {
        flutterWebviewPlugin.hide();
        loadkah = true;
        titleloading = "Preparing to Step 3 - Bike Features";
      } else if (urls.contains("/payment")) {
        flutterWebviewPlugin.hide();
        loadkah = true;
        titleloading = "Preparing to Step 4 - Checkout Payment";
      } else if (urls.contains("_express-checkout")) {
        flutterWebviewPlugin.hide();
        loadkah = true;
        titleloading = "Processing PayPal Checkout";
      } else if (urls.contains("changedate")) {
        Navigator.pop(context);
        Navigator.pop(context);
      } else if (urls.contains("error")) {
        Navigator.pop(context);
        Navigator.pop(context);
      } else if (urls.contains("status")) {
        CustomerBook();
      } else if (urls.contains("final")) {
        var separated = urls.split("/");
        String idbooking = separated[5];
        print("ID BOOK1: " + idbooking);
        flutterWebviewPlugin.hide();
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return new AlertDialog(
                backgroundColor: PrimaryColor,
                title: new Text(
                  "Success! Please to upload your driver licence for a verification",
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text(
                      "Click to Continue",
                      style: new TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      //DetailBook(id: idbooking,);
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (context) => new DetailBook(
                                id: idbooking,
                              )));
                    },
                  )
                ],
              );
            });
      }

      if (loadkah) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return new Container(
                  child: new Center(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(10),
                        child: Center(child: new CircularProgressIndicator())),
                    new Text(titleloading,
                        textAlign: TextAlign.center,
                        style:
                            new TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ));
            });
      }
    });

    flutterWebviewPlugin.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        /*flutterWebviewPlugin.evalJavascript('location.href').then((String hasil) {
          skrg = hasil;

        });*/

        //hide universal widget disini
        if (loadkah) {
          Navigator.pop(context);
          flutterWebviewPlugin.show();
        }
        print("done : " + urls);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new MaterialApp(
      routes: {
        "/": (_) => new WebviewScaffold(
              withZoom: true,
              withLocalStorage: true,
              hidden: false,
              initialChild: Container(
                child: new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ),
              withJavascript: true,
              appCacheEnabled: true,
              url: loadurls,
              appBar: new AppBar(
                leading: new IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      flutterWebviewPlugin.hide();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return new AlertDialog(
                              backgroundColor: PrimaryColor,
                              title: new Text(
                                "Are you sure you want to close this reservation?",
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold),
                              ),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text(
                                    "Close Reservation",
                                    style:
                                        new TextStyle(color: Colors.redAccent),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                ),
                                new FlatButton(
                                  child: new Text(
                                    "Do not Cancel",
                                    style: new TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    flutterWebviewPlugin.show();
                                  },
                                ),
                              ],
                            );
                          });
                    }),
                backgroundColor: SecondaryColor,
                title: new Image.asset(
                  "asset/img/bananaz_logo_apps.png",
                  height: 50,
                ),
                centerTitle: true,
              ),
            ),
      },
    ));
  }
}

class CustomScrollPhysics extends ScrollPhysics {
  final double itemDimension;

  CustomScrollPhysics({this.itemDimension, ScrollPhysics parent})
      : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysics(
        itemDimension: itemDimension, parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position, double portion) {
    return (position.pixels + portion) / itemDimension;
  }

  double _getPixels(double page, double portion) {
    return (page * itemDimension) - portion;
  }

  double _getTargetPixels(
    ScrollPosition position,
    Tolerance tolerance,
    double velocity,
    double portion,
  ) {
    double page = _getPage(position, portion);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(page.roundToDouble(), portion);
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent))
      return super.createBallisticSimulation(position, velocity);

    final Tolerance tolerance = this.tolerance;
    final portion = (position.extentInside - itemDimension) / 2;
    final double target =
        _getTargetPixels(position, tolerance, velocity, portion);
    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

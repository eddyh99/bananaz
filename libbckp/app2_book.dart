import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import "package:flutter/material.dart";
import 'package:flutter/material.dart' as prefix0;
//import 'package:flutter/material.dart' as prefix0;
import 'package:path/path.dart' as Path;
import 'package:async/async.dart';
import 'package:image_picker/image_picker.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_share_plugin/social_share_plugin.dart';
//import 'package:image/image.dart' as Img;
//import 'package:flutter_absolute_path/flutter_absolute_path.dart';
//import 'package:path_provider/path_provider.dart';

import 'on_going_promo.dart';
import 'main_home.dart';

class CustomerBookProvider {
  List customerBookData;

  Future<void> getCustomerBookData({idCustomer}) async {
    http.Response data = await http
        .get("https://dev.bananaz.co/ios/mybooking/?id_customer=" + idCustomer);
    var jsonData = jsonDecode(data.body);
    customerBookData = jsonData;
  }
}

class CustomerBookBloc {
  final CustomerBookProvider customerBookProvider = new CustomerBookProvider();

  final StreamController customerBookController =
      new StreamController.broadcast();

  Stream get customerBookStreamer => customerBookController.stream;

  Future<String> idCustomer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("id_customer");
    return id;
  }

  Future<void> getCustomerBookDataBloc() async {
    var id = await idCustomer();
    await customerBookProvider.getCustomerBookData(idCustomer: id);
    customerBookController.sink.add(customerBookProvider.customerBookData);
  }

  void dispose() {
    customerBookController.close();
  }
}

class CustomerBook extends StatefulWidget {
  final CustomerBookProvider customerBookProvider = new CustomerBookProvider();
  final CustomerBookBloc customerBookBloc = new CustomerBookBloc();

  @override
  _CustomerBookState createState() => _CustomerBookState();
}

class _CustomerBookState extends State<CustomerBook> {
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = new FirebaseMessaging();

  Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  @override
  void initState() {
    this.widget.customerBookBloc.getCustomerBookDataBloc();
    super.initState();
    if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("Message Message"+message["title"]);
        if(message["message"]=="MyBookingResultActivity"){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>DetailBook(id: message["id"],)
          ));
        } else if(message["message"]=="HomeActivity"){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>MainHome()
          ));
        } else if(message["message"]=="PromoActivity"){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>OnGoingPromoPush(idPromotion: message["id"],)
          ));
        }
        return new AlertDialog(
          title: new Text(message["title"]),
          content: new Text(message["message"]),
          actions: <Widget>[
            new FlatButton(
              color: Colors.lightBlueAccent,
              textColor: Colors.white,
              child: new Text("Close"),
              onPressed: ()=>Navigator.pop(context),
            ),
            new FlatButton(
              color: Colors.lightBlueAccent,
              textColor: Colors.white,
              child: new Text("More .."),
              onPressed: (){

              },
            ),
          ],
        );
      },
      onResume: (Map<String, dynamic> message) async {
        print("on Message : $message");
        if(message["message"]=="MyBookingResultActivity"){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>DetailBook(id: message["id"],)
          ));
        } else if(message["message"]=="HomeActivity"){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>MainHome()
          ));
        } else if(message["message"]=="PromoActivity"){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>OnGoingPromoPush(idPromotion: message["id"],)
          ));
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("Launch App2 Message"+message["title"]);
        if(message["message"]=="MyBookingResultActivity"){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>DetailBook(id: message["id"],)
          ));
        } else if(message["message"]=="HomeActivity"){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>MainHome()
          ));
        } else if(message["message"]=="PromoActivity"){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context)=>OnGoingPromoPush(idPromotion: message["id"],)
          ));
        }
      },
    );
  }

  _saveDeviceToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString("uid");

    String fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      var tokenRef = _db
          .collection("users")
          .document(uid)
          .collection("tokens")
          .document("fcmToken");

      await tokenRef.setData({
        "token": fcmToken,
        "created at": FieldValue.serverTimestamp(),
        "platform": Platform.operatingSystem
      });
    }
  }

  final oCcy = new NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: new StreamBuilder(
      stream: this.widget.customerBookBloc.customerBookStreamer,
      initialData: this.widget.customerBookProvider.customerBookData,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return new Center(
            child: new CircularProgressIndicator(),
          );
        } else if (snapshot.data.length == 0) {
          return new ListView(
            children: <Widget>[
              new Container(
                padding: new EdgeInsets.all(15),
                child: new Card(
                  elevation: 3,
                  child: Container(
                      padding: EdgeInsets.all(15),
                      child: new Text("You don't have any booking yet")),
                ),
              )
            ],
          );
        } else {
          return new Center(
            child: new ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, i) {
//                  var date= DateTime.fromMicrosecondsSinceEpoch(int.parse(snapshot.data[i]["timestamp"])).toString().substring(0,19);
                return new FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => DetailBook(
                              id: snapshot.data[i]["id"],
                            )));
                  },
                  child: new Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                    child: new Card(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(6)),
                      child: Column(
                        children: <Widget>[
                          new Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Text("ID : " +
                                    snapshot.data[i]["reservation_id"]),
                                new Text(
                                  "Rp. " +
                                      oCcy.format(
                                          int.parse(snapshot.data[i]["total"])),
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          new Container(
                            width: double.infinity,
                            decoration: new BoxDecoration(
                                gradient: snapshot.data[i]["status"] ==
                                        "Payment Received"
                                    ? new LinearGradient(colors: [
                                        Colors.greenAccent,
                                        Colors.lightGreenAccent
                                      ])
                                    : new LinearGradient(colors: [
                                        Colors.orangeAccent,
                                        Colors.orange
                                      ])),
                            padding: EdgeInsets.all(7),
                            child: new Text(
                              snapshot.data[i]["nama_motor"],
                              style: new TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          new Container(
                            padding: EdgeInsets.all(6),
                            child: new Text(snapshot.data[i]["tanggal"]),
                          ),
                          new Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Text(snapshot.data[i]["status"]),
                                new Text(
                                  "Show Details",
                                  style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    ));
  }
}

class DetailBookProvider {
  List bookingDetailData;
  List featuresData;
  Map statusBookData;

  Future<void> getBookingDetailData({id}) async {
    http.Response data =
        await http.get("https://dev.bananaz.co/ios/mybookingid/?id=" + id);
    var jsonData = jsonDecode(data.body);
    bookingDetailData = jsonData;
  }

  Future<void> getFeatures({id}) async {
    http.Response data =
        await http.get("https://dev.bananaz.co/ios/myfeatures/?id=" + id);
    var jsonData = jsonDecode(data.body);
    featuresData = jsonData;
  }

  Future<void> getStatusBook({id}) async {
    http.Response dataDetail =
        await http.get("https://dev.bananaz.co/ios/mybookingid/?id=" + id);
    var jsonDataDetail = jsonDecode(dataDetail.body);
    //print(jsonDataDetail);
    http.Response data =
        await http.get("https://dev.bananaz.co/ios/getstatus/?id=" + jsonDataDetail[0]["reservation_id"]);
    var jsonData = jsonDecode(data.body);
    statusBookData = jsonData;
    statusBookData["status_return"] = jsonDataDetail[0]["status_return"];
    statusBookData["status_pickup"] = jsonDataDetail[0]["status_pickup"];
  }
}

class DetailBookBloc {
  final DetailBookProvider _detailBookProvider = new DetailBookProvider();

  final StreamController _detailBookController =
      new StreamController.broadcast();
  final StreamController _featuresController = new StreamController.broadcast();
  final StreamController _statusController = new StreamController.broadcast();

  Stream get _detailBookStreamer => _detailBookController.stream;
  Stream get _featuresStreamer => _featuresController.stream;
  Stream get _statusStreamer => _statusController.stream;

  Future<void> getBookingDetailDataBloc({id}) async {
    await _detailBookProvider.getBookingDetailData(id: id);
    _detailBookController.sink.add(_detailBookProvider.bookingDetailData);
  }

  Future<void> getFeaturesBloc({id}) async {
    await _detailBookProvider.getFeatures(id: id);
    _featuresController.sink.add(_detailBookProvider.featuresData);
  }

  Future<void> getStatusBloc({id}) async {
    await _detailBookProvider.getStatusBook(id: id);
    _statusController.sink.add(_detailBookProvider.statusBookData);
  }

  void dispose() {
    _detailBookController.close();
    _featuresController.close();
    _statusController.close();
  }
}

class DetailBook extends StatefulWidget {
  final String id;

  DetailBook({this.id});

  final DetailBookProvider _detailBookProvider = new DetailBookProvider();
  final DetailBookBloc _detailBookBloc = new DetailBookBloc();

  @override
  _DetailBookState createState() => _DetailBookState();
}

class _DetailBookState extends State<DetailBook> {
  final oCcy = new NumberFormat.decimalPattern();
  List detailBookData;
  List features;

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future<bool> upload(File imageFile) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse("https://dev.bananaz.co/ios/uploadfoto");

    var req = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile("file", stream, length,
        filename: Path.basename(imageFile.path));
    req.fields["id"] = this.widget.id;
    req.files.add(multipartFile);

    var response = await req.send();
    if (response.statusCode == 200) {
      print("Image Uploaded");
    } else {
      print("Upload Failed");
    }
    var getStatus;
    await response.stream.transform(utf8.decoder).listen((value) {
      var res = jsonDecode(value);
      if (res["error"]) {
        getStatus = false;
      } else {
        getStatus = true;
      }
    });
    return getStatus;
  }

  Future<bool> updateStatusReservasi({String id, int type}) async {
    print(id);
    print(type);
    var str = "https://dev.bananaz.co/ios/updatestatusreservasi/?id=" +
        id +
        "&type=$type";
    print(str);
    http.Response status = await http.get(str);
    var jsonStatus = jsonDecode(status.body);
    if (jsonStatus["status"] == "1") {
      if (type == 1) {
        showDialog(
            context: context,
            builder: (context) {
              return new AlertDialog(
                backgroundColor: Colors.orangeAccent,
                title: new Text("Succeed!",style: new TextStyle(fontWeight: FontWeight.bold),),
                content: new Text("Pickup Confirmation Succeed!"),
                actions: <Widget>[
                  new FlatButton(
                    textColor: Colors.black,
                    child: new Text("DISCOUNT INFO!",style: new TextStyle(fontWeight: FontWeight.bold),),
                    onPressed: () {
                      setState(() {

                      });
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) {
                            return new AlertDialog(
                              backgroundColor: Colors.orangeAccent,
                              title: new Text(
                                  "Get Discount for the next reservation",style: new TextStyle(fontWeight: FontWeight.bold),),
                              content: new Text(
                                  "Are you sure you want to get a discount for the next reservation? just take a photo of you with our scooter and post it on your Facebook. After that we will send your coupon by email"),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text("Yes",style: new TextStyle(fontWeight: FontWeight.bold),),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    this.widget._detailBookBloc.getBookingDetailDataBloc(id:this.widget.id);
                                    File file = await ImagePicker.pickImage(
                                        source: ImageSource.camera);
                                    await SocialSharePlugin.shareToFeedFacebook(
                                        'caption', file.path);
                                  },
                                  color: Colors.transparent,
                                  textColor: Colors.black,
                                ),
                                new FlatButton(
                                  child: new Text("No",style: new TextStyle(fontWeight: FontWeight.bold),),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    this.widget._detailBookBloc.getBookingDetailDataBloc(id:this.widget.id);
                                  },
                                  color: Colors.transparent,
                                  textColor: Colors.red,
                                ),
                              ],
                            );
                          });
                    },
                  ),
                ],
              );
            });
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return new AlertDialog(
                backgroundColor: Colors.orangeAccent,
                title: new Text("Succeed!",style:new TextStyle(fontWeight: FontWeight.bold)),
                content: new Text("Return Confirmation Succeed!"),
                actions: <Widget>[
                  new FlatButton(
                    textColor: Colors.black,
                    child: new Text("Discount Info!",style:new TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {

                      });
                      showDialog(
                          context: context,
                          builder: (context) {
                            return new AlertDialog(
                              backgroundColor: Colors.orangeAccent,
                              title: new Text(
                                  "Get Discount for the next reservation",style:new TextStyle(fontWeight: FontWeight.bold)),
                              content: new Text(
                                  "Are you sure you want to get a discount for the next reservation? Just give 5 starts for our page on TripAdvisor. After that we will send your coupon by email"),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text("Yes",style:new TextStyle(fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    this.widget._detailBookBloc.getBookingDetailDataBloc(id:this.widget.id);
                                    const url =
                                        'https://www.tripadvisor.com/Profile/bananazbali';
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  color: Colors.transparent,
                                  textColor: Colors.black,
                                ),
                                new FlatButton(
                                  child: new Text("No",style:new TextStyle(fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    this.widget._detailBookBloc.getBookingDetailDataBloc(id:this.widget.id);
                                  },
                                  color: Colors.transparent,
                                  textColor: Colors.red,
                                ),
                              ],
                            );
                          });
                    },
                  ),
                ],
              );
            });
      }
      return true;
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return new AlertDialog(
              title: new Text("Failed!"),
              content: new Text("Failed"),
            );
          });
      return false;
    }
  }

  @override
  void initState() {
    this.widget._detailBookBloc.getBookingDetailDataBloc(id: this.widget.id);
    this.widget._detailBookBloc.getFeaturesBloc(id: this.widget.id);
    this.widget._detailBookBloc.getStatusBloc(id: this.widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: ()=>Navigator.pop(context),
        ),
        title: new Image.asset(
          "asset/img/bananaz_logo_apps.png",
          height: 50,
        ),
        centerTitle: true,
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            new Container(
              width: double.infinity,
              height: 30,
              color: Colors.lightBlueAccent,
            ),
            new StreamBuilder(
              stream: this.widget._detailBookBloc._detailBookStreamer,
              initialData: this.widget._detailBookProvider.bookingDetailData,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    child: new Center(
                      child: new Container(),
                    ),
                  );
                } else {
                  return new Container(
                    transform: Matrix4.translationValues(0, -25, 0),
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: new SingleChildScrollView(
                      child: Center(
                        child: Card(
                          child: Container(
                            width: double.infinity,
                            padding: new EdgeInsets.symmetric(vertical: 8),
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
//                        Profile
                                new Container(
                                    child: new Column(
                                  children: <Widget>[
                                    new Container(
                                      padding: EdgeInsets.all(2),
                                      child: new Text(
                                          "Booking id : ${snapshot.data[0]["id"]}"),
                                    ),
                                    new Container(
                                      padding: EdgeInsets.all(8),
                                      child: new Text(
                                        snapshot.data[0]["status"],
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ),
                                    new Container(
                                      width: double.infinity,
                                      decoration: new BoxDecoration(
                                          gradient: new LinearGradient(
                                              colors: snapshot.data[0]
                                                          ["status"] ==
                                                      "Payment Pending"
                                                  ? [
                                                      Colors.orangeAccent,
                                                      Colors.orange
                                                    ]
                                                  : [
                                                      Colors.greenAccent,
                                                      Colors.lightGreenAccent
                                                    ])),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: new Text(
                                          snapshot.data[0]["nama_motor"],
                                          style: new TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    new Container(
                                      padding: EdgeInsets.all(8),
                                      child: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Text(
                                            "Total Price",
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          new Text(
                                            "Rp. " +
                                                oCcy.format(int.parse(
                                                    snapshot.data[0]["total"])),
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )),

                                new Container(
                                  padding: EdgeInsets.all(8),
                                  child: new Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      new Text(
                                        "Pickup Date",
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      new Text(snapshot.data[0]["pick_up"])
                                    ],
                                  ),
                                ),

                                new Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: new Text(
                                      snapshot.data[0]["pick_up_location"]),
                                ),

                                new SizedBox(
                                  height: 20,
                                ),

                                new Container(
                                  padding: EdgeInsets.all(8),
                                  child: new Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      new Text(
                                        "Return Date",
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      new Text(snapshot.data[0]["return"])
                                    ],
                                  ),
                                ),

                                new Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: new Text(
                                      snapshot.data[0]["return_location"]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            new Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                child: new StreamBuilder(
                  stream: this.widget._detailBookBloc._statusStreamer,
                  initialData: this.widget._detailBookProvider.statusBookData,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return new Container();
                    } else {
                      if (snapshot.data['status'] == 'rental') {
                        if (snapshot.data["status_return"] == "0" &&
                            snapshot.data["after_30_return"] == "yes") {
                          return new Container(
                            child: Column(
                              children: <Widget>[
                                new Container(
                                  width:double.infinity,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(10),
                                  child: new Text("RENT",
                                      style:
                                      new TextStyle(color: Colors.white,fontSize: 14)),
                                  color: Colors.lightBlueAccent,
                                ),
                                new RaisedButton(
                                  child: new Text("RETURN CONFIRMATION", style: new TextStyle(fontSize: 17,fontWeight: FontWeight.bold, color:Colors.black)),
                                  textColor: Colors.black,
                                  color:Colors.yellowAccent,
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return new AlertDialog(
                                            backgroundColor: Colors.orangeAccent,
                                            title: new Text(
                                              "Return Confirmation",
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            content: new Text(
                                                "Are you sure want to confirming Return?"),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text("Yes"),
                                                color: Colors.lightBlueAccent,
                                                textColor: Colors.black,
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Center(
                                                            child:
                                                            new CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),));
                                                      });
                                                  var statusConfirmation =
                                                  await updateStatusReservasi(
                                                      id: this.widget.id,
                                                      type: 2);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              new FlatButton(
                                                textColor: Colors.black,
                                                color: Colors.redAccent,
                                                child: new Text("Cancel"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          return new Container(
                            child: new RaisedButton(
                              child: new Text("Completed"),
                              color: Colors.lightBlueAccent,
                              textColor: Colors.white,
                              onPressed: () => print("Completed"),
                            ),
                          );
                        }
                      } else {
                        if (snapshot.data["status"] == 'open' &&
                            snapshot.data["after_30_pickup"] == "yes") {
                          if (snapshot.data["status_pickup"] == "0") {
                            return new Container(
                              child: Column(
                                children: <Widget>[
                                  new Container(
                                    width:double.infinity,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(10),
                                    child: new Text("OPEN",
                                        style:
                                        new TextStyle(color: Colors.white,fontSize: 14)),
                                    color: Colors.lightBlueAccent,
                                  ),
                                  new RaisedButton(
                                    child: new Text("PICKUP CONFIRMATION", style: new TextStyle(fontSize: 17,fontWeight: FontWeight.bold, color:Colors.black)),
                                    textColor: Colors.black,
                                    color:Colors.yellowAccent,
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return new AlertDialog(
                                              backgroundColor: Colors.orangeAccent,
                                              title: new Text(
                                                "Pickup Confirmation",
                                                style: new TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold),
                                              ),
                                              content: new Text(
                                                  "Are you sure want to confirming pickup?"),
                                              actions: <Widget>[
                                                new FlatButton(
                                                  child: new Text("Yes",style: new TextStyle(fontWeight: FontWeight.bold),),
                                                  color: Colors.transparent,
                                                  textColor: Colors.black,
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return Center(
                                                              child:
                                                              new CircularProgressIndicator());
                                                        });
                                                    await updateStatusReservasi(
                                                        id: this.widget.id,
                                                        type: 1);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                new FlatButton(
                                                  textColor: Colors.red,
                                                  color: Colors.transparent,
                                                  child: new Text("Cancel",style: new TextStyle(fontWeight: FontWeight.bold),),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return new Container(
                              child: Column(
                                children: <Widget>[
                                  new Container(
                                    width:double.infinity,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(10),
                                    child: new Text("RENT",
                                        style:
                                        new TextStyle(color: Colors.white,fontSize: 14)),
                                    color: Colors.lightBlueAccent,
                                  ),
                                  new RaisedButton(
                                    child: new Text("RETURN CONFIRMATION", style: new TextStyle(fontSize: 17,fontWeight: FontWeight.bold, color:Colors.black)),
                                    textColor: Colors.black,
                                    color:Colors.yellowAccent,
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return new AlertDialog(
                                              backgroundColor: Colors.orangeAccent,
                                              title: new Text(
                                                "Return Confirmation",
                                                style: new TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold),
                                              ),
                                              content: new Text(
                                                  "Are you sure want to confirming Return?"),
                                              actions: <Widget>[
                                                new FlatButton(
                                                  child: new Text("Yes",style:new TextStyle(fontWeight: FontWeight.bold)),
                                                  color: Colors.transparent,
                                                  textColor: Colors.black,
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return Center(
                                                              child:
                                                              new CircularProgressIndicator());
                                                        });
                                                    var statusConfirmation =
                                                    await updateStatusReservasi(
                                                        id: this.widget.id,
                                                        type: 2);
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                new FlatButton(
                                                  textColor: Colors.redAccent,
                                                  color: Colors.transparent,
                                                  child: new Text("Cancel",style:new TextStyle(fontWeight: FontWeight.bold)),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          return new Container(
                              child: new RaisedButton(
                                child: new Text("COMPLETED", style: new TextStyle(fontSize: 17,fontWeight: FontWeight.bold, color:Colors.white)),
                                textColor: Colors.white,
                                color:Colors.blueAccent,
                                onPressed: () => print("Completed"),
                              ));
                        }
                      }
                    }
                  },
                )),
            GestureDetector(
              onTap: getImage,
              child: new Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: <Widget>[
                    new Card(
                        elevation: .7,
                        child: new StreamBuilder(
                          stream:
                              this.widget._detailBookBloc._detailBookStreamer,
                          initialData:
                              this.widget._detailBookProvider.bookingDetailData,
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return new Container();
                            } else {
                              return new Container(
                                child: _image == null
                                    ? snapshot.data[0]["licence"] == null
                                        ? Icon(Icons.add_a_photo)
                                        : new Image.network(
                                            "https://dev.bananaz.co/assets/upload/image/${snapshot.data[0]['licence']}",
                                            height: 180,
                                          )
                                    : new Image.file(_image),
                              );
                            }
                          },
                        )),
                    new Card(
                      elevation: .7,
                      child: new Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              _image == null
                                  ? "Upload Your Driver's License Photo"
                                  : "Change Your Driver's License Photo",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            new Container(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: new Icon(
                                Icons.add_a_photo,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    new GestureDetector(
                      onTap: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return new Center(
                                child: new CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),),
                              );
                            });
                        var statusUpload = await upload(_image);
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: (context) {
                              return new Dialog(
                                backgroundColor: Colors.orangeAccent,
                                child: new Container(
                                  padding: EdgeInsets.all(10),
                                  child: new Text(statusUpload
                                      ? "Upload Succeed"
                                      : "Upload Failed",style: new TextStyle(fontWeight: FontWeight.bold),),
                                ),
                              );
                            });
                      },
                      child: _image != null
                          ? new Card(
                              elevation: .7,
                              child: new Container(
                                color: Colors.orangeAccent,
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                child: new Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Text(
                                      "Send",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : new Container(),
                    )
                  ],
                ),
              ),
            ),
            new Container(
              padding: EdgeInsets.all(10),
              child: new StreamBuilder(
                stream: this.widget._detailBookBloc._featuresStreamer,
                initialData: this.widget._detailBookProvider.featuresData,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {}
                  if (snapshot.data == null) {
                    return new Center(
                      child: new CircularProgressIndicator(),
                    );
                  } else if (snapshot.data.length == 0) {
                    return Container(
                      child: new Text("No features"),
                    );
                  } else {
                    return new ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, i) {
                        return new ListTile(
                          title: new Text(
                            snapshot.data[i]["name"],
                          ),
                          trailing: new Text(snapshot.data[i]["qty"]),
                        );
                      },
                    );
                  }
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}

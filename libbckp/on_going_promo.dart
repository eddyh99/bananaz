import 'dart:convert';

import 'package:devbananaz/main_home.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;


class OnGoingPromo extends StatefulWidget {

  String idPromotion = "";
  String judulPromotion =  "";
  String isiPromotion =  "";
  String tanggalPost =  "";
  String image=  "";

  OnGoingPromo({
    this.idPromotion,
    this.judulPromotion,
    this.isiPromotion,
    this.tanggalPost,
    this.image,
});

  @override
  _OnGoingPromoState createState() => _OnGoingPromoState();
}

class _OnGoingPromoState extends State<OnGoingPromo> {
  void openWhatsApp({name}) async {
    var whatsappUrl = "https://api.whatsapp.com/send?phone=6281908992019&text=Hi Bananaz, I'm $name. Can you help me ?";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw "could find that url";
    }
  }

  String _parseHtmlString(String htmlText) {
    var document = parse(htmlText);
    String parsedString = parse(document.body.text).documentElement.text;
    return parsedString;
  }

  Future<void> getDataPromo() async {
    print("get data : " + this.widget.idPromotion);
    http.Response data = await http.get(
        "https://dev.bananaz.co/ios/promoid/?id=${this.widget.idPromotion}");
    var jsonData = jsonDecode(data.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(this.widget.judulPromotion == ""){
      return Scaffold(
          appBar: new AppBar(
          leading: new IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
    onPressed: () => Navigator.pop(context),
    ),
    title: new Image.asset(
    "asset/img/bananaz_logo_apps.png",
    height: 50,
    ),
    centerTitle: true,
    ));
    } else{
    return Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: new Image.asset(
          "asset/img/bananaz_logo_apps.png",
          height: 50,
        ),
        centerTitle: true,
      ),
      body: new Container(
          child: new ListView(
            children: <Widget>[
              new Hero(
                tag: this.widget.idPromotion,
                child: new Image.network(
                    "https://dev.bananaz.co/assets/upload/image/${this.widget
                        .image}"
                ),
              ),
              new Container(
                transform: Matrix4.translationValues(0, -15, 0),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: new Card(
                  child: new Column(
                    children: <Widget>[
                      new Text(
                        widget.judulPromotion,
                        style: new TextStyle(
                          fontSize: 35,
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),

              new Container(
                transform: Matrix4.translationValues(0, 0, 0),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: new Card(
                  child: new Column(
                    children: <Widget>[
                      new Text(
                        this._parseHtmlString(widget.isiPromotion),
                        style: new TextStyle(
                            fontSize: 20
                        ),
                      )
                    ],
                  ),
                ),
              ),

            ],
          )
      ),
    );
  }

}
}


class OnGoingPromoPush extends StatefulWidget {

  String idPromotion;

  OnGoingPromoPush({this.idPromotion});

  @override
  _OnGoingPromoPushState createState() => _OnGoingPromoPushState();
}

class _OnGoingPromoPushState extends State<OnGoingPromoPush> {

  var dataPromo;

  Future<dynamic> getDataPromo() async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    http.Response data = await http.get(
        "https://dev.bananaz.co/ios/promoid/?id="+this.widget.idPromotion);
    var jsonData = jsonDecode(data.body);
    return jsonData;
  }

  String _parseHtmlString(String htmlText) {
    var document = parse(htmlText);
    String parsedString = parse(document.body.text).documentElement.text;
    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: new Image.asset(
          "asset/img/bananaz_logo_apps.png",
          height: 50,
        ),
        centerTitle: true,
      ),
      body: new FutureBuilder(
        future: getDataPromo(),
        initialData: null,
        builder: (context,snapshot){
          if(snapshot.data == null){
            return new Container(
              child: new Center(
                child: new CircularProgressIndicator(),
              ),
            );
          }else{
            return new Container(
                child: new ListView(
                  children: <Widget>[
                    new Hero(
                      tag: snapshot.data[0]["id_promotion"],
                      child: new Image.network(
                          "https://dev.bananaz.co/assets/upload/image/${snapshot.data[0]["gambar"]}"
                      ),
                    ),
                    new Container(
                      transform: Matrix4.translationValues(0, -15, 0),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: new Card(
                        child: new Column(
                          children: <Widget>[
                            new Text(
                              snapshot.data[0]["judul_promotion"],
                              style: new TextStyle(
                                fontSize: 35,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),

                    new Container(
                      transform: Matrix4.translationValues(0, 0, 0),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: new Card(
                        child: new Column(
                          children: <Widget>[
                            new Text(
                              this._parseHtmlString(snapshot.data[0]["isi_promotion"]),
                              style: new TextStyle(
                                  fontSize: 20
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                  ],
                )
            );
          }
        },
      ),
    );
  }
}

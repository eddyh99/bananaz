import 'dart:convert';

import 'package:devbananaz/app1_home.dart';
import 'package:devbananaz/main.dart';
import 'package:devbananaz/app4_logout.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_markdown/flutter_markdown.dart';


const SecondaryColor =  Color(0xff62BBF9);
class Pages extends StatefulWidget {

  String idPages = "";
  String judulPages =  "";
  String isiPages =  "";
  String tanggalPost =  "";

  Pages({
    this.idPages,
    this.judulPages,
    this.isiPages,
    this.tanggalPost,
});

  @override
  _PagesState createState() => _PagesState();
}

class _PagesState extends State<Pages> {

  String _parseHtmlString(String htmlText) {
    var document = parse(htmlText);
    String parsedString = parse(document.body.text).documentElement.text;
    return parsedString;
  }

  Future<void> getDataPages() async {
    print("get data : " + this.widget.idPages);
    http.Response data = await http.get(
        "https://www.bananaz.co/ios/pages/?id=${this.widget.idPages}");
    var jsonData = jsonDecode(data.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(this.widget.judulPages == ""){
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
              new Container(
                transform: Matrix4.translationValues(0, -15, 0),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: new Card(
                  child: new Column(
                    children: <Widget>[
                      new Text(
                        widget.judulPages,
                        style: new TextStyle(
                          fontSize: 24, color:PrimaryColor
                        ),
                        textAlign: TextAlign.left,
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
                      new MarkdownBody(
                        data: html2md.convert(widget.isiPages),
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


class PagesPush extends StatefulWidget {

  String idPages;

  PagesPush({this.idPages});

  @override
  _PagesPushState createState() => _PagesPushState();
}

class _PagesPushState extends State<PagesPush> {

  var dataPages;

  Future<dynamic> getDataPages() async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    http.Response data = await http.get(
        "https://www.bananaz.co/ios/pages/?id="+this.widget.idPages);
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
        future: getDataPages(),
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
                    new Container(
                      transform: Matrix4.translationValues(0, 0, 0),
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: new Card(
                        child: new Column(
                          children: <Widget>[
                            new Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                                child:
                                new Text(
                                  snapshot.data["judul_berita"],
                                  style: new TextStyle(
                                      fontSize: 24
                                  ),
                                  textAlign: TextAlign.left,

                                )
                            ),
                            new Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 4),
                            child:  new MarkdownBody(
                              data: html2md.convert(snapshot.data["isi_berita"]),
                            )
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

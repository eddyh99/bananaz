import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'app1_home.dart';
import 'app2_book.dart';
import 'app3_inbox.dart';
import 'app4_logout.dart';

class MainHome extends StatefulWidget {
  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> with TickerProviderStateMixin {
  TabController _tabController;

  int _cIndex = 0;

  List<Widget> layers = [
    AppPage1(),
    CustomerBook(),
    CustomerInbox(),
    CustomerHelp(),
    CustomerLogout(),
  ];



  void _incrementIndex(index) {
    setState(() {
      _cIndex = index;
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: ()async=>false,
        child: new Scaffold(
        appBar: new AppBar(
          title: new Image.asset(
            "asset/img/bananaz_logo_apps.png",
            height: 50,
          ),
          centerTitle: true,
        ),
        body: layers[_cIndex],
        bottomNavigationBar: new BottomNavigationBar(
          selectedIconTheme: new IconThemeData(
            color: Colors.lightBlueAccent,
          ),
          selectedLabelStyle: new TextStyle(
            color: Colors.lightBlueAccent
          ),
          backgroundColor: Colors.white,
          elevation: 3.5,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.black87,
          iconSize: 20,
          items: <BottomNavigationBarItem>[
            new BottomNavigationBarItem(
                title: new Text("Home"), icon: new Icon(Icons.home)),
            new BottomNavigationBarItem(
                title: new Text("My Booking"), icon: new Icon(Icons.calendar_today)),
            new BottomNavigationBarItem(
                title: new Text("Inbox"), icon: new Icon(Icons.inbox)),
            new BottomNavigationBarItem(
                title: new Text("CS Support"), icon: new Icon(Icons.phone)),
            new BottomNavigationBarItem(
                title: new Text("Logout"), icon: new Icon(Icons.home)),
          ],
          currentIndex: _cIndex,
          onTap: _incrementIndex,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

class CustomerHelp extends StatefulWidget {
  @override
  _CustomerHelpState createState() => _CustomerHelpState();
}

class _CustomerHelpState extends State<CustomerHelp> {

  Future<void> openWhatsApp() async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    var name=prefs.getString("first_name");
    var sliceName=name == null ? "..." : name;
    var whatsappUrl ="https://api.whatsapp.com/send?phone=6281908992019&text=Hi Bananaz, I'm $sliceName. Can you help me ?";
    if(await canLaunch(whatsappUrl)){
      await launch(whatsappUrl);
      Navigator.of(context).push(new MaterialPageRoute(
        builder: (context)=>new MainHome()
      ));
    }else{
      throw "could find that url";
    }
  }

  void whatsAppOpen() async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    var name=prefs.getString("first_name");
    var sliceName=name == null ? "..." : name;
    await FlutterLaunch.launchWathsApp(phone: "6281908992019", message: "Hi Bananaz, I'm $sliceName. Can you help me ");
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (context)=>new MainHome()
    ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    whatsAppOpen();

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context,snapshot){
        return new Container();
      },
    );
  }
}

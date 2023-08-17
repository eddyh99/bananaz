import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const PrimaryColor =  Color(0xffFFC300);
const SecondaryColor =  Color(0xff62BBF9);
class CustomerInboxProvider{
  List customerInboxData;

  Future<void>getCustomerInboxData()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    var idCustomer=prefs.getString("id_customer");
    http.Response data=await http.get("https://www.bananaz.co/ios/myinbox/?id_customer=$idCustomer");
    var jsonData=jsonDecode(data.body);
    customerInboxData = jsonData;
  }

}

class CustomerInboxBloc{
  final CustomerInboxProvider customerInboxProvider = new CustomerInboxProvider();

  final StreamController customerInboxController=new StreamController.broadcast();

  Stream get customerInboxStreamer => customerInboxController.stream;

  Future<void>getCustomerInboxBloc()async{
    await customerInboxProvider.getCustomerInboxData();
    customerInboxController.sink.add(customerInboxProvider.customerInboxData);
  }

  void dispose(){
    customerInboxController.close();
  }
}

class CustomerInbox extends StatefulWidget {
  
  final CustomerInboxProvider customerInboxProvider = new CustomerInboxProvider();
  final CustomerInboxBloc customerInboxBloc = new CustomerInboxBloc();

  @override
  _CustomerInboxState createState() => _CustomerInboxState();
}

class _CustomerInboxState extends State<CustomerInbox> {

  Future<String>getCustomerId()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    var id=prefs.getString("id_customer");
    return id;
  }

  @override
  void initState() {
    var id=getCustomerId();
    this.widget.customerInboxBloc.getCustomerInboxBloc(
    );
    print(id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new StreamBuilder(
        stream: this.widget.customerInboxBloc.customerInboxStreamer,
        initialData: this.widget.customerInboxProvider.customerInboxData,
        builder: (context,snapshot){
          if(snapshot.data == null){
            return new Center(
              child: new CircularProgressIndicator(),
            );
          } else{
            Iterable snapshotReversed=snapshot.data.reversed;
            var reversed=snapshotReversed.toList();
            return new Center(
              child: new ListView.builder(
                itemCount: reversed.length,
                itemBuilder: (context,i){
                  var date= DateTime.fromMillisecondsSinceEpoch(int.parse(reversed[i]["timestamp"])*1000).toString().substring(0,19);
                  return new FlatButton(
                    onPressed: ()=>print("MANTAP"),
                                                          child: new Container(
                      padding: EdgeInsets.symmetric(vertical:8,horizontal: 2),
                      child: new Card(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(6)
                        ),
                        child: Column(
                          children: <Widget>[
                            new Container(
                              padding: EdgeInsets.all(8),
                              child: new Text(
                                "Date: "+date
                              ),
                            ),
                            new Container(
                              width: double.infinity,
                              decoration: new BoxDecoration(
                                gradient: reversed[i]["type"] == "notif"
                                ? new LinearGradient(
                                  colors: [
                                    Colors.black,
                                    Colors.black
                                  ]
                                )
                                : new LinearGradient(
                                  colors: [
                                    SecondaryColor,
                                    SecondaryColor
                                  ]
                                )
                              ),
                              padding: EdgeInsets.all(7),
                              child: new Text(
                                reversed[i]["title"] == null ? "Message":reversed[i]["title"],
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            new Container(
                              padding: EdgeInsets.all(8),
                              child: new Text(
                                  reversed[i]["message"]
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
      ),
    );
  }
}
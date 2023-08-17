import 'dart:async';
import 'dart:convert';
import 'package:devbananaz/main_home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';


const PrimaryColor =  Color(0xffFFC300);
const SecondaryColor =  Color(0xff62BBF9);

class CountryProvider{
  List countryData = new List();

  var countryList=[
    {"name": "Afghanistan", "code": "AF"},
    {"name": "Åland Islands", "code": "AX"},
    {"name": "Albania", "code": "AL"},
    {"name": "Algeria", "code": "DZ"},
    {"name": "American Samoa", "code": "AS"},
    {"name": "AndorrA", "code": "AD"},
    {"name": "Angola", "code": "AO"},
    {"name": "Anguilla", "code": "AI"},
    {"name": "Antarctica", "code": "AQ"},
    {"name": "Antigua and Barbuda", "code": "AG"},
    {"name": "Argentina", "code": "AR"},
    {"name": "Armenia", "code": "AM"},
    {"name": "Aruba", "code": "AW"},
    {"name": "Australia", "code": "AU"},
    {"name": "Austria", "code": "AT"},
    {"name": "Azerbaijan", "code": "AZ"},
    {"name": "Bahamas", "code": "BS"},
    {"name": "Bahrain", "code": "BH"},
    {"name": "Bangladesh", "code": "BD"},
    {"name": "Barbados", "code": "BB"},
    {"name": "Belarus", "code": "BY"},
    {"name": "Belgium", "code": "BE"},
    {"name": "Belize", "code": "BZ"},
    {"name": "Benin", "code": "BJ"},
    {"name": "Bermuda", "code": "BM"},
    {"name": "Bhutan", "code": "BT"},
    {"name": "Bolivia", "code": "BO"},
    {"name": "Bosnia and Herzegovina", "code": "BA"},
    {"name": "Botswana", "code": "BW"},
    {"name": "Bouvet Island", "code": "BV"},
    {"name": "Brazil", "code": "BR"},
    {"name": "British Indian Ocean Territory", "code": "IO"},
    {"name": "Brunei Darussalam", "code": "BN"},
    {"name": "Bulgaria", "code": "BG"},
    {"name": "Burkina Faso", "code": "BF"},
    {"name": "Burundi", "code": "BI"},
    {"name": "Cambodia", "code": "KH"},
    {"name": "Cameroon", "code": "CM"},
    {"name": "Canada", "code": "CA"},
    {"name": "Cape Verde", "code": "CV"},
    {"name": "Cayman Islands", "code": "KY"},
    {"name": "Central African Republic", "code": "CF"},
    {"name": "Chad", "code": "TD"},
    {"name": "Chile", "code": "CL"},
    {"name": "China", "code": "CN"},
    {"name": "Christmas Island", "code": "CX"},
    {"name": "Cocos (Keeling) Islands", "code": "CC"},
    {"name": "Colombia", "code": "CO"},
    {"name": "Comoros", "code": "KM"},
    {"name": "Congo", "code": "CG"},
    {"name": "Congo, The Democratic Republic of the", "code": "CD"},
    {"name": "Cook Islands", "code": "CK"},
    {"name": "Costa Rica", "code": "CR"},
    {"name": "Cote DIvoire", "code": "CI"},
    {"name": "Croatia", "code": "HR"},
    {"name": "Cuba", "code": "CU"},
    {"name": "Cyprus", "code": "CY"},
    {"name": "Czech Republic", "code": "CZ"},
    {"name": "Denmark", "code": "DK"},
    {"name": "Djibouti", "code": "DJ"},
    {"name": "Dominica", "code": "DM"},
    {"name": "Dominican Republic", "code": "DO"},
    {"name": "Ecuador", "code": "EC"},
    {"name": "Egypt", "code": "EG"},
    {"name": "El Salvador", "code": "SV"},
    {"name": "Equatorial Guinea", "code": "GQ"},
    {"name": "Eritrea", "code": "ER"},
    {"name": "Estonia", "code": "EE"},
    {"name": "Ethiopia", "code": "ET"},
    {"name": "Falkland Islands (Malvinas)", "code": "FK"},
    {"name": "Faroe Islands", "code": "FO"},
    {"name": "Fiji", "code": "FJ"},
    {"name": "Finland", "code": "FI"},
    {"name": "France", "code": "FR"},
    {"name": "French Guiana", "code": "GF"},
    {"name": "French Polynesia", "code": "PF"},
    {"name": "French Southern Territories", "code": "TF"},
    {"name": "Gabon", "code": "GA"},
    {"name": "Gambia", "code": "GM"},
    {"name": "Georgia", "code": "GE"},
    {"name": "Germany", "code": "DE"},
    {"name": "Ghana", "code": "GH"},
    {"name": "Gibraltar", "code": "GI"},
    {"name": "Greece", "code": "GR"},
    {"name": "Greenland", "code": "GL"},
    {"name": "Grenada", "code": "GD"},
    {"name": "Guadeloupe", "code": "GP"},
    {"name": "Guam", "code": "GU"},
    {"name": "Guatemala", "code": "GT"},
    {"name": "Guernsey", "code": "GG"},
    {"name": "Guinea", "code": "GN"},
    {"name": "Guinea-Bissau", "code": "GW"},
    {"name": "Guyana", "code": "GY"},
    {"name": "Haiti", "code": "HT"},
    {"name": "Heard Island and Mcdonald Islands", "code": "HM"},
    {"name": "Holy See (Vatican City State)", "code": "VA"},
    {"name": "Honduras", "code": "HN"},
    {"name": "Hong Kong", "code": "HK"},
    {"name": "Hungary", "code": "HU"},
    {"name": "Iceland", "code": "IS"},
    {"name": "India", "code": "IN"},
    {"name": "Indonesia", "code": "ID"},
    {"name": "Iran, Islamic Republic Of", "code": "IR"},
    {"name": "Iraq", "code": "IQ"},
    {"name": "Ireland", "code": "IE"},
    {"name": "Isle of Man", "code": "IM"},
    {"name": "Israel", "code": "IL"},
    {"name": "Italy", "code": "IT"},
    {"name": "Jamaica", "code": "JM"},
    {"name": "Japan", "code": "JP"},
    {"name": "Jersey", "code": "JE"},
    {"name": "Jordan", "code": "JO"},
    {"name": "Kazakhstan", "code": "KZ"},
    {"name": "Kenya", "code": "KE"},
    {"name": "Kiribati", "code": "KI"},
    {"name": "Korea, Democratic People'S Republic of", "code": "KP"},
    {"name": "Korea, Republic of", "code": "KR"},
    {"name": "Kuwait", "code": "KW"},
    {"name": "Kyrgyzstan", "code": "KG"},
    {"name": "Lao People'S Democratic Republic", "code": "LA"},
    {"name": "Latvia", "code": "LV"},
    {"name": "Lebanon", "code": "LB"},
    {"name": "Lesotho", "code": "LS"},
    {"name": "Liberia", "code": "LR"},
    {"name": "Libyan Arab Jamahiriya", "code": "LY"},
    {"name": "Liechtenstein", "code": "LI"},
    {"name": "Lithuania", "code": "LT"},
    {"name": "Luxembourg", "code": "LU"},
    {"name": "Macao", "code": "MO"},
    {"name": "Macedonia, The Former Yugoslav Republic of", "code": "MK"},
    {"name": "Madagascar", "code": "MG"},
    {"name": "Malawi", "code": "MW"},
    {"name": "Malaysia", "code": "MY"},
    {"name": "Maldives", "code": "MV"},
    {"name": "Mali", "code": "ML"},
    {"name": "Malta", "code": "MT"},
    {"name": "Marshall Islands", "code": "MH"},
    {"name": "Martinique", "code": "MQ"},
    {"name": "Mauritania", "code": "MR"},
    {"name": "Mauritius", "code": "MU"},
    {"name": "Mayotte", "code": "YT"},
    {"name": "Mexico", "code": "MX"},
    {"name": "Micronesia, Federated States of", "code": "FM"},
    {"name": "Moldova, Republic of", "code": "MD"},
    {"name": "Monaco", "code": "MC"},
    {"name": "Mongolia", "code": "MN"},
    {"name": "Montserrat", "code": "MS"},
    {"name": "Morocco", "code": "MA"},
    {"name": "Mozambique", "code": "MZ"},
    {"name": "Myanmar", "code": "MM"},
    {"name": "Namibia", "code": "NA"},
    {"name": "Nauru", "code": "NR"},
    {"name": "Nepal", "code": "NP"},
    {"name": "Netherlands", "code": "NL"},
    {"name": "Netherlands Antilles", "code": "AN"},
    {"name": "New Caledonia", "code": "NC"},
    {"name": "New Zealand", "code": "NZ"},
    {"name": "Nicaragua", "code": "NI"},
    {"name": "Niger", "code": "NE"},
    {"name": "Nigeria", "code": "NG"},
    {"name": "Niue", "code": "NU"},
    {"name": "Norfolk Island", "code": "NF"},
    {"name": "Northern Mariana Islands", "code": "MP"},
    {"name": "Norway", "code": "NO"},
    {"name": "Oman", "code": "OM"},
    {"name": "Pakistan", "code": "PK"},
    {"name": "Palau", "code": "PW"},
    {"name": "Palestinian Territory, Occupied", "code": "PS"},
    {"name": "Panama", "code": "PA"},
    {"name": "Papua New Guinea", "code": "PG"},
    {"name": "Paraguay", "code": "PY"},
    {"name": "Peru", "code": "PE"},
    {"name": "Philippines", "code": "PH"},
    {"name": "Pitcairn", "code": "PN"},
    {"name": "Poland", "code": "PL"},
    {"name": "Portugal", "code": "PT"},
    {"name": "Puerto Rico", "code": "PR"},
    {"name": "Qatar", "code": "QA"},
    {"name": "Reunion", "code": "RE"},
    {"name": "Romania", "code": "RO"},
    {"name": "Russian Federation", "code": "RU"},
    {"name": "RWANDA", "code": "RW"},
    {"name": "Saint Helena", "code": "SH"},
    {"name": "Saint Kitts and Nevis", "code": "KN"},
    {"name": "Saint Lucia", "code": "LC"},
    {"name": "Saint Pierre and Miquelon", "code": "PM"},
    {"name": "Saint Vincent and the Grenadines", "code": "VC"},
    {"name": "Samoa", "code": "WS"},
    {"name": "San Marino", "code": "SM"},
    {"name": "Sao Tome and Principe", "code": "ST"},
    {"name": "Saudi Arabia", "code": "SA"},
    {"name": "Senegal", "code": "SN"},
    {"name": "Serbia and Montenegro", "code": "CS"},
    {"name": "Seychelles", "code": "SC"},
    {"name": "Sierra Leone", "code": "SL"},
    {"name": "Singapore", "code": "SG"},
    {"name": "Slovakia", "code": "SK"},
    {"name": "Slovenia", "code": "SI"},
    {"name": "Solomon Islands", "code": "SB"},
    {"name": "Somalia", "code": "SO"},
    {"name": "South Africa", "code": "ZA"},
    {"name": "South Georgia and the South Sandwich Islands", "code": "GS"},
    {"name": "Spain", "code": "ES"},
    {"name": "Sri Lanka", "code": "LK"},
    {"name": "Sudan", "code": "SD"},
    {"name": "Suriname", "code": "SR"},
    {"name": "Svalbard and Jan Mayen", "code": "SJ"},
    {"name": "Swaziland", "code": "SZ"},
    {"name": "Sweden", "code": "SE"},
    {"name": "Switzerland", "code": "CH"},
    {"name": "Syrian Arab Republic", "code": "SY"},
    {"name": "Taiwan, Province of China", "code": "TW"},
    {"name": "Tajikistan", "code": "TJ"},
    {"name": "Tanzania, United Republic of", "code": "TZ"},
    {"name": "Thailand", "code": "TH"},
    {"name": "Timor-Leste", "code": "TL"},
    {"name": "Togo", "code": "TG"},
    {"name": "Tokelau", "code": "TK"},
    {"name": "Tonga", "code": "TO"},
    {"name": "Trinidad and Tobago", "code": "TT"},
    {"name": "Tunisia", "code": "TN"},
    {"name": "Turkey", "code": "TR"},
    {"name": "Turkmenistan", "code": "TM"},
    {"name": "Turks and Caicos Islands", "code": "TC"},
    {"name": "Tuvalu", "code": "TV"},
    {"name": "Uganda", "code": "UG"},
    {"name": "Ukraine", "code": "UA"},
    {"name": "United Arab Emirates", "code": "AE"},
    {"name": "United Kingdom", "code": "GB"},
    {"name": "United States", "code": "US"},
    {"name": "United States Minor Outlying Islands", "code": "UM"},
    {"name": "Uruguay", "code": "UY"},
    {"name": "Uzbekistan", "code": "UZ"},
    {"name": "Vanuatu", "code": "VU"},
    {"name": "Venezuela", "code": "VE"},
    {"name": "Viet Nam", "code": "VN"},
    {"name": "Virgin Islands, British", "code": "VG"},
    {"name": "Virgin Islands, U.S.", "code": "VI"},
    {"name": "Wallis and Futuna", "code": "WF"},
    {"name": "Western Sahara", "code": "EH"},
    {"name": "Yemen", "code": "YE"},
    {"name": "Zambia", "code": "ZM"},
    {"name": "Zimbabwe", "code": "ZW"}
  ];

  Future<List<dynamic>> getCountryData({value})async{
    var display=countryList.where((f)=>f["name"].toLowerCase().contains(value)).toList();
    countryData = display;
  }
}

class CountryBloc{

  final CountryProvider _countryProvider = new CountryProvider();

  final StreamController _countryController = new StreamController.broadcast();

  Stream get _countryStreamer => _countryController.stream;

  Future<void> getCountry({value})async{
    _countryProvider.getCountryData(value:value);
    _countryController.sink.add(_countryProvider.countryData);
  }

  void dispose(){
    _countryController.close();
  }

}

class SignUp extends StatefulWidget {

  final String email;
  final String name;
  final String phoneNumber;
  final String token;

  final CountryProvider _countryProvider = new CountryProvider();
  final CountryBloc _countryBloc = new CountryBloc();

  SignUp({this.email,this.name,this.phoneNumber,this.token});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _countryNameController=new TextEditingController();
  TextEditingController _phoneNumberController=new TextEditingController();
  TextEditingController _addressController = new TextEditingController();
  TextEditingController _cityNameController=new TextEditingController();
  TextEditingController _zipController=new TextEditingController();

  String _emptyValidation(value){
    if(value == ''){
      return "this field cannot be empty";
    } else {
      return null;
    }
  }




  String choiceCountry;

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      setState(() {
        _validated=true;
      });
    }
  }

  @override
  void initState() {
    _firstNameController.text=this.widget.name;
    _lastNameController.text=this.widget.name;
    _phoneNumberController.text=this.widget.phoneNumber;
    super.initState();
  }

  var _validated = false;

  var _formKey=GlobalKey<FormState>();

  bool countrySearch=false;


  _onCountryFocus(){
    showDialog(
        context: context,
        builder: (context){
          return new Container(
            padding: new EdgeInsets.all(9),
            child: new Material(
              child: new SingleChildScrollView(
                child: StreamBuilder(
                    stream: this.widget._countryBloc._countryStreamer,
                    initialData: this.widget._countryProvider.countryData,
                    builder: (context, snapshot) {
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Container(
                            width: double.infinity,
                            child: new FlatButton(
                              child: new Text("close",style: new TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold),),
                              onPressed: ()=>Navigator.pop(context),
                            ),
                          ),
                          new TextFormField(
                            enableInteractiveSelection:true,
                            autofocus: true,
                            validator: (value){
                              if(value==""){
                                return "Country field cannot be empty";
                              }return null;
                            },
                            controller: _countryNameController,
                            onChanged: (value){
                              this.widget._countryBloc.getCountry(value: value);
                            },
                            autocorrect: false,
                            cursorColor: Colors.lightBlueAccent,
                            cursorWidth: .9,
                            style: new TextStyle(
                                color: Colors.black,
                                fontStyle: FontStyle.normal),
                            decoration: new InputDecoration(
                              prefixIcon: new Icon(
                                Icons.location_on,
                                color: Colors.redAccent,
                              ),
                              suffixIcon: new IconButton(icon: new Icon(Icons.cancel), onPressed:(){
                                _countryNameController.text="";
                                this.widget._countryBloc.getCountry(value: "");
                              }),
                              labelText: "Country",
                              alignLabelWithHint: true,
                              labelStyle: new TextStyle(fontSize: 13.8),
                              enabledBorder: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                    color: Colors.lightBlueAccent,
                                    width: .5,
                                  )),
                              border: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                    color: Colors.lightBlueAccent,
                                    width: .5,
                                  )),
                              focusedBorder: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                    color: Colors.lightBlueAccent,
                                    width: .5,
                                  )),
                            ),
                          ),

                          new Container(
                            child: new ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context,i){
                                return new ListTile(
                                  title: new Text(snapshot.data[i]["name"]),
                                  onTap: (){
                                    setState(() {
                                      _countryNameController.text=snapshot.data[i]["name"];
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                ),
              ),
            ),
          );
        }
    );
  }

  String _phoneNumberValidator(value){
    Pattern pattern =
        r'^[0-9\-\+]{5,15}$';
    RegExp regex = new RegExp(pattern);
    if(value == ""){
      return "This field cannot be empty";
    } else {
      if (!regex.hasMatch(value)){
        print("TIDAK VALID");
        return 'Enter Valid Phone Number';
      } else {
        print("OKE");
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        padding: EdgeInsets.all(10),
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Colors.lightBlue, Colors.lightBlueAccent])),
        child: Center(
          child: new SingleChildScrollView(
            child: new Form(
              key: _formKey,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.all(20),
                    child: new Image.asset(
                      "asset/img/bananaz_logo_apps.png",
                      width: 275,
                    ),
                    margin: EdgeInsets.only(bottom: 35),
                  ),
                  new Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: new Text(
                      "Step 1",
                      style: new TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.all(5),
                    child: new Row(
                      children: <Widget>[
                        new Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new TextFormField(
                              controller: _firstNameController,
                              validator: _emptyValidation,
                              autocorrect: false,
                              cursorColor: Colors.white,
                              cursorWidth: .9,
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.normal),
                              decoration: new InputDecoration(
                                labelText: "First Name",
                                alignLabelWithHint: true,
                                labelStyle: new TextStyle(
                                    fontSize: 13.8, color: Colors.white),
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
                        ),
                        new Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new TextFormField(
                              controller: _lastNameController,
                              validator: _emptyValidation,
                              autocorrect: false,
                              cursorColor: Colors.white,
                              cursorWidth: .9,
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.normal),
                              decoration: new InputDecoration(
                                labelText: "Last Name",
                                alignLabelWithHint: true,
                                labelStyle: new TextStyle(
                                    fontSize: 13.8, color: Colors.white),
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
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.all(5),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Container(
                              transform: new Matrix4.translationValues(0, 5, 0),
                              decoration: new BoxDecoration(
                                border: new Border(bottom: new BorderSide(color: Colors.white,width: .5)),
//                                  borderRadius: new BorderRadius.circular(4)
                              ),
                              child: new FlatButton(
                                onPressed: (){
                                  _onCountryFocus();
                                },
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Expanded(child: new Text(_countryNameController.text==""?"Country":_countryNameController.text,textAlign: TextAlign.left,style: new TextStyle(color: Colors.white),))
                                  ],
                                ),
                              )
                          ),
                        ),
                        new Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              validator: _phoneNumberValidator,
                              autocorrect: false,
                              cursorColor: Colors.white,
                              cursorWidth: .9,
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.normal),
                              decoration: new InputDecoration(
                                labelText: "Phone Number",
                                alignLabelWithHint: true,
                                labelStyle: new TextStyle(
                                    fontSize: 13.8, color: Colors.white),
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
                        ),
                      ],
                    ),
                  ),

                  new Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: new TextFormField(
                      controller: _addressController,
                      validator: _emptyValidation,
                      autocorrect: false,
                      cursorColor: Colors.white,
                      cursorWidth: .9,
                      style: new TextStyle(
                          color: Colors.white, fontStyle: FontStyle.normal),
                      decoration: new InputDecoration(
                        labelText: "Address",
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
                    padding: EdgeInsets.all(5),
                    child: new Row(
                      children: <Widget>[
                        new Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new TextFormField(
                              controller: _cityNameController,
                              validator: _emptyValidation,
                              autocorrect: false,
                              cursorColor: Colors.white,
                              cursorWidth: .9,
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.normal),
                              decoration: new InputDecoration(
                                labelText: "City",
                                alignLabelWithHint: true,
                                labelStyle: new TextStyle(
                                    fontSize: 13.8, color: Colors.white),
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
                        ),
                        new Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new TextFormField(
                              controller: _zipController,
                              keyboardType: TextInputType.number,
                              validator: _emptyValidation,
                              autocorrect: false,
                              cursorColor: Colors.white,
                              cursorWidth: .9,
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.normal),
                              decoration: new InputDecoration(
                                labelText: "Zip Code",
                                alignLabelWithHint: true,
                                labelStyle: new TextStyle(
                                    fontSize: 13.8, color: Colors.white),
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
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    width: double.infinity,
                    child: new RaisedButton(
                      onPressed: () {
                        _validateInputs();
                        if(_validated){
                          Navigator.of(context).push(new MaterialPageRoute(
                              builder: (context)=>new SignUpJoin(
                                  firstName: _firstNameController.text,
                                  lastName: _lastNameController.text,
                                  countryName: _countryNameController.text,
                                  phoneNumber: _phoneNumberController.text,
                                  address: _addressController.text,
                                  city: _cityNameController.text,
                                  zipcode: _zipController.text,
                                  token:this.widget.token,
                                  email: this.widget.email
                              )
                          ));
                        }
                      },
                      child: new Text(
                        "NEXT",
                        style: new TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      elevation: .4,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(50)),
                      color: PrimaryColor,
                      textColor: Colors.white,
                    ),
                  ),
                  new SizedBox(height: 15,),
                  new Container(
                    child: new GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            "Already have an account ?",
                            style: new TextStyle(color: Colors.white),
                          ),
                          new Text(
                            " Login here",
                            style: new TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpJoin extends StatefulWidget {

  final String firstName;
  final String lastName;
  final String countryName;
  final String phoneNumber;
  final String address;
  final String city;
  final String zipcode;
  final String token;
  final String email;

  SignUpJoin({
    this.firstName,
    this.lastName,
    this.countryName,
    this.phoneNumber,
    this.address,
    this.city,
    this.zipcode,
    this.token,
    this.email});

  @override
  _SignUpJoinState createState() => _SignUpJoinState();
}

class _SignUpJoinState extends State<SignUpJoin> {

  Future<bool> doLogin({email, password,token}) async {
    http.Response userData = await http.get(
        "https://www.bananaz.co/ios/login/?email=$email&password=$password&android_id=$token");
    var jsonData = jsonDecode(userData.body);
    if (jsonData["status"] == "1") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("session_status", true);
      prefs.setString("email",jsonData["email"]);
      prefs.setString("first_name",jsonData["first_name"]);
      prefs.setString("last_name",jsonData["last_name"]);
      prefs.setString("phone_number",jsonData["phone_number"]);
      prefs.setString("address",jsonData["address"]);
      prefs.setString("city",jsonData["city"]);
      prefs.setString("zip_code",jsonData["zip_code"]);
      prefs.setString("country",jsonData["country"]);
      prefs.setString("status",jsonData["status"]);
      prefs.setString("android_id",prefs.getString("fcmToken"));
      prefs.setString("id_customer",jsonData["id_customer"]);
      return true;
    } else if (jsonData["status"] == "2") {
      return false;
    }return null;
  }

  Future<bool>doRegister({Map data})async{
    print(data);
    http.Response rq=await http.post("https://www.bananaz.co/ios/register",body: data);
    var jsonData=jsonDecode(rq.body);
    if(jsonData["status"] == "1"){
      print("berhasil");
      return true;
    }else{
      print("tidak berhasil");
      return false;
    }
  }

  var _formKey=GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String _emptyValidation(value){
    if(value == ''){
      return "this field cannot be empty";
    } else {
      return "";
    }
  }

  String _emailValidation(value){
    if(value == ''){
      return "email cannot be empty";
    }
    RegExp regExp = new RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if(!regExp.hasMatch(value)){
      return "Enter valid email";
    }else{
      return null;
    }
  }



  var _validated=false;

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      setState(() {
        _validated=true;
      });
    }
  }

  String _passwordValidation(value){
    if(value != _passwordController.text){
      return "Re-Typed password must be same with Password field";
    } return null;
  }

  Future<String> _getId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
  @override
  void initState() {
    _emailController.text=this.widget.email == null ? "":this.widget.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        padding: EdgeInsets.all(10),
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Colors.lightBlue, Colors.lightBlueAccent])),
        child: new Center(
          child: new SingleChildScrollView(
            child: new Form(
              key: _formKey,
              child: new Column(
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.all(20),
                    child: new Image.asset(
                      "asset/img/bananaz_logo_apps.png",
                      width: 275,
                    ),
                    margin: EdgeInsets.only(bottom: 35),
                  ),
                  new Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: new Text(
                      "Step 2",
                      style: new TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.all(10),
                    child: new TextFormField(
                      controller: _emailController,
                      validator: _emailValidation,
                      autocorrect: false,
                      cursorColor: Colors.white,
                      cursorWidth: .9,
                      style: new TextStyle(
                          color: Colors.white, fontStyle: FontStyle.normal),
                      decoration: new InputDecoration(
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
                    padding: EdgeInsets.all(10),
                    child: new TextFormField(
                      validator: (value){
                        if(value.length <= 7){
                          return "Password must be more than 7 characters, that includes letters, number and special characters.";
                        } return null;
                      },
                      controller: _passwordController,
                      obscureText: true,
                      autocorrect: false,
                      cursorColor: Colors.white,
                      cursorWidth: .9,
                      style: new TextStyle(
                          color: Colors.white, fontStyle: FontStyle.normal),
                      decoration: new InputDecoration(
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
                    padding: EdgeInsets.all(10),
                    child: new TextFormField(
                      validator: _passwordValidation,
                      obscureText: true,
                      autocorrect: false,
                      cursorColor: Colors.white,
                      cursorWidth: .9,
                      style: new TextStyle(
                          color: Colors.white, fontStyle: FontStyle.normal),
                      decoration: new InputDecoration(
                        labelText: "Re-Type Password",
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
                    padding: EdgeInsets.all(15),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new RawMaterialButton(
                          elevation: .5,
                          shape: CircleBorder(),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          fillColor: PrimaryColor,
                          child: new Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: new RaisedButton(
                            child: new Text(
                              "JOIN",
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19
                              ),
                            ),
                            color: PrimaryColor,
                            textColor: Colors.white,
                            onPressed: ()async{
                              String deviceId=await _getId();
                              _validateInputs();
                              if(_validated){
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return new Dialog(
                                        child: Container(
                                          padding: new EdgeInsets.all(5),
                                          child: new ListView(
                                            shrinkWrap: true,
                                            children: <Widget>[
                                              new Container(
                                                  padding: new EdgeInsets.all(8),
                                                  child: Center(
                                                      child:
                                                      new CircularProgressIndicator())),
                                              new Container(
                                                  padding: new EdgeInsets.all(8),
                                                  child: Center(
                                                      child: new Text("Loading"))),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                var fcmtoken = prefs.getString("fcmToken");
                                var regisStatus=await doRegister(data: {
                                  "first_name":this.widget.firstName,
                                  "last_name":this.widget.lastName,
                                  "phone_number":this.widget.phoneNumber,
                                  "country":this.widget.countryName,
                                  "address":this.widget.address,
                                  "city":this.widget.city,
                                  "zip_code":this.widget.zipcode,
                                  "email":_emailController.text,
                                  "password":_passwordController.text,
                                  "android_id":fcmtoken
                                });
                                var loginStatus=await doLogin(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    token: fcmtoken
                                );
                                if(loginStatus){
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          builder: (context)=>new MainHome()
                                      )
                                  );
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context){
                                        return new Dialog(
                                          child: new Text("Login Failed, Please login manually on login page"),
                                        );
                                      }
                                  );
                                }
                              }
                            },
                            elevation: .5,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(50)),
                          ),
                        )
                      ],
                    ),
                  ),
                  new SizedBox(height: 15,),
                  new Container(
                    child: new GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            "Already have an account ?",
                            style: new TextStyle(color: Colors.white),
                          ),
                          new Text(
                            " Login here",
                            style: new TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

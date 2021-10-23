import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'lines_loading.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigo[500],
        fontFamily: "Segoe UI"
      ),
      
      home: const MyHomePage(title: 'BusCloud'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String homeStation = "";
  String schoolStation = "";
  List<dynamic> stations = [];
  List<String> stationNames = [];
  final String url = "api.buscloud.ml";
  var datetime = DateFormat("yyyy-MM-dd").format(DateTime.now());
  bool latest_arrival_required = false;
  var latest_arrival_time = TimeOfDay.now();

  var startLines;
  var endLines;

  final time_margin_controller = TextEditingController();
  final early_time_margin_controller = TextEditingController();
  final username_controller = TextEditingController();
  final password_controller = TextEditingController();

  bool _validateTimeMargin = true;
  bool _validateEarlyTimeMargin = true;
  bool _validateUsername = true;
  bool _validatePassword = true;
  bool _validateHomeStation = true;
  bool _validateSchoolStation = true;


  Future<String> getStations() async {
    var res = await http.get(Uri.https(url, "/api/v1/getstations"));
    var resBody = res.body;
    /* print(resBody); */

    return resBody;
  }

  Future<List<String>> getStationNames() async {
    List<dynamic> stat = [];
    stat = jsonDecode(await getStations());
    List<String> statNames = [];
    /* stat.forEach((key, value) {
      statNames.add(value["lineName"]);
    }); */

    stat.forEach((element) {
      statNames.add(element["lineName"]);
    });

    return statNames;
  }

  @override
  void initState() {
    super.initState();
    getStations().then((value) => setState(() {
      stations = jsonDecode(value);
    }));
    getStationNames().then((value) => setState(() {
      stationNames = value;
    }));
  }

  bool _validate(controller) {
    if (controller.text != "") {
      return true;
    }
    return false;
  }

  bool _validateHome() {
    if (homeStation != "") {
        return true;
    }
    return false;
  }

  bool _validateSchool() {
    if (schoolStation != "") {
        return true;
    }
    return false;
  }


  bool _inputValid() {
    setState(() {
      _validateEarlyTimeMargin = _validate(early_time_margin_controller);
      _validatePassword = _validate(password_controller);
      _validateTimeMargin = _validate(time_margin_controller);
      _validateUsername = _validate(username_controller);
      _validateHomeStation = _validateHome();
      _validateSchoolStation = _validateSchool();
    });
    

    if (_validateEarlyTimeMargin) {
      if (_validatePassword) {
        if (_validateTimeMargin) {
          if (_validateUsername) {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  } 

  void _pushDataAndLoad() {
    if (_inputValid()) {
      var toSchoolJson = {"start_station": homeStation, "end_station": schoolStation, "date": datetime, "time_margin": time_margin_controller.text, 
                         "early_time_margin": early_time_margin_controller.text, "username": username_controller.text, "password": password_controller.text};

      var fromSchoolJson = {"start_station": schoolStation, "end_station": homeStation, "date": datetime, "early_time_margin": time_margin_controller.text, 
                           "username": username_controller.text, "password": password_controller.text};

      Navigator.push(context,
        MaterialPageRoute(builder: (_) => LinesLoadingPage(linesToData: toSchoolJson, linesFromData: fromSchoolJson)),
      );
    }
  }

  void setHomeStation(str) {
    stations.forEach((element) {
      if (element["lineName"] == str) {
        homeStation = element["lineId"];
      }
    });
    print(homeStation);
  }

  void setSchoolStation(str) {
    stations.forEach((element) {
      if (element["lineName"] == str) {
        schoolStation = element["lineId"];
      }
    });
    print(schoolStation);
  }

  Future<void> _showDatePicker()async{
    var picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if(picked != null) {
      print(DateFormat("yyyy-MM-dd").format(picked));
      setState(() {
        datetime = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  Future<void> _showTimePicker()async{
    var picked = await showTimePicker(context: context,initialTime: TimeOfDay.now());
    if(picked != null) {
      print(picked.format(context));
      setState(() {
        latest_arrival_time = picked;
      });
    }
  }

  void _toggleLatest() {
    setState(() {
      latest_arrival_required = !latest_arrival_required;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            
          },
        ),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: [
            Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      DropdownSearch<String>(
                        mode: Mode.MENU,
                        showSearchBox: true,
                        items: stationNames,
                        label: "Home Station",
                        hint: "Stations",
                        popupItemDisabled: (String s) => s.startsWith('I'),
                        onChanged: setHomeStation,
                        dropdownSearchDecoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          errorText: _validateSchoolStation ? null : "Please pick a station",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownSearch<String>(
                          mode: Mode.MENU,
                          showSearchBox: true,
                          items: stationNames,
                          label: "School Station",
                          hint: "Stations",
                          popupItemDisabled: (String s) => s.startsWith('I'),
                          onChanged: setSchoolStation,
                          dropdownSearchDecoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                            errorText: _validateSchoolStation ? null : "Please pick a station",
                            border: OutlineInputBorder(),
                          ),
                      ),
                    ],
                  )
                ),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: time_margin_controller,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Time Margin",
                            errorText: _validateTimeMargin ? null : "Value can\'t be empty",
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Flexible(
                        child: TextField(
                          controller: early_time_margin_controller,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Early Time Margin",
                            errorText: _validateEarlyTimeMargin ? null : "Value can\'t be empty",
                          )
                        )
                      ),
                    ],
                  )
                ),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: username_controller,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Username",
                            errorText: _validateUsername ? null : "Value can\'t be empty",
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Flexible(
                        child: TextField(  
                          controller: password_controller,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Password",
                            errorText: _validatePassword ? null : "Value can\'t be empty",
                          )
                        )
                      ),
                    ],
                  )
                ),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: OutlinedButton(
                          onPressed: _showDatePicker,
                          style: OutlinedButton.styleFrom(
                            primary: Colors.grey,
                            minimumSize: Size(88, 36),
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            side: BorderSide(color: Colors.grey),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(3.0)),
                            ),
                          ),
                          
                          child: Text("Date: " + datetime.toString(),
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      ),
                      SizedBox(width: 5.0),
                      /* Expanded(
                        flex: 5,
                        child: OutlinedButton(
                          onPressed: _toggleLatest,
                          style: OutlinedButton.styleFrom(
                            primary: Colors.grey,
                            minimumSize: Size(88, 36),
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            side: BorderSide(color: Colors.grey),
                            backgroundColor: latest_arrival_required ? Colors.black38 : Color(0xff2E2E2E),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(3.0)),
                            ),
                          ),
                          
                          child: Text("Latest Arrival Required",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      ) */
                    ],
                  ),
                ),
                /* SizedBox(height: 10),
                Container(
                  child: Visibility(
                    visible: latest_arrival_required,
                    child: Flexible(
                      child: OutlinedButton(
                        onPressed: _showTimePicker,
                        style: OutlinedButton.styleFrom(
                          primary: Colors.grey,
                          minimumSize: Size(88, 36),
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          side: BorderSide(color: Colors.grey),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(3.0)),
                          ),
                        ),
                        child: Text("Latest Arrival: " + latest_arrival_time.format(context),
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    ),
                  ),
                ) */
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pushDataAndLoad,
        tooltip: 'Search',
        child: const Icon(Icons.search),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'lines_loading.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusCloud',
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

  String initialTimeMargin = "";
  String initialEarlyTimeMargin = "";
  String initialUsername = "";
  String initialPassword = "";

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

  Future<void> storeQuery() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("home_station_id", homeStation);
    prefs.setString("school_station_id", schoolStation);
    prefs.setString("time_margin", time_margin_controller.text);
    prefs.setString("early_time_margin", early_time_margin_controller.text);
    prefs.setString("username", username_controller.text);
    prefs.setString("password", password_controller.text);
  }

  Future<List<dynamic>> readStoredQuery() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? home_station_id = prefs.getString("home_station_id");
    String? school_station_id = prefs.getString("school_station_id");
    String? time_margin = prefs.getString("time_margin");
    String? early_time_margin = prefs.getString("early_time_margin");
    String? username_ = prefs.getString("username");
    String? password_ = prefs.getString("password");
    
    return [home_station_id, time_margin, early_time_margin, username_, password_];
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

      storeQuery();

      Navigator.push(context,
        MaterialPageRoute(builder: (_) => LinesLoadingPage(linesToData: toSchoolJson, linesFromData: fromSchoolJson, stations: stations)),
      );
    }
  }

  void setHomeStation(str) {
    stations.forEach((element) {
      if (element["lineName"] == str) {
        homeStation = element["lineId"];
      }
    });
  }

  void setSchoolStation(str) {
    stations.forEach((element) {
      if (element["lineName"] == str) {
        schoolStation = element["lineId"];
      }
    });
  }

  Future<void> _showDatePicker()async{
    var picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if(picked != null) {
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
        child: FutureBuilder(
          future: [readStoredQuery(), getStations(), getStationNames()],
          builder: (context, snapshot),
        )
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

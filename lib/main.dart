import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

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
  Object? _startStation;
  Map<String, dynamic> stations = {};
  List<String> stationNames = [];
  final String url = "api.buscloud.ml";

  Future<String> getStations() async {
    var res = await http.get(Uri.https(url, "/api/v1/getstations"));
    var resBody = res.body;
    print(resBody);

    return resBody;
  }

  Future<List<String>> getStationNames() async {
    Map<String, dynamic> stat = {};
    stat = jsonDecode(await getStations());
    List<String> statNames = [];
    stat.forEach((key, value) {
      statNames.add(value["lineName"]);
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


  void _search() {
    setState(() {
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
        child: DropdownSearch<String>(
            mode: Mode.MENU,
            items: stationNames,
            label: "Menu mode",
            hint: "Stations",
            popupItemDisabled: (String s) => s.startsWith('I'),
            onChanged: print,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _search,
        tooltip: 'Search',
        child: const Icon(Icons.search),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List stations = [];
  final String url = "api.buscloud.ml";

  Future<String> getStations() async {
    var res = await http.get(Uri.https(url, "/api/v1/getstations"));
    var resBody = json.decode(res.body);

    setState(() {
      stations = resBody;
    });

    print(resBody);

    return "Success";
  }

  @override
  void initState() {
    super.initState();
    this.getStations();
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
        child: DropdownButton(
          items: stations.map((item) {
            return DropdownMenuItem(
              child: Text(item['item_name']),
              value: item['id'].toString(),
            );
          }).toList(),
          onChanged: (newVal) {
            setState(() {
              _startStation = newVal;
            });
          },
          value: _startStation,
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

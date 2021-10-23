import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

class LinesLoadingPage extends StatefulWidget {
  @required final Map<String, dynamic>? linesToData;
  @required final Map<String, dynamic>? linesFromData;

  const LinesLoadingPage({Key? key, required this.linesToData, required this.linesFromData})
      : super(key: key);  @override
  _LinesLoadingPageState createState() => _LinesLoadingPageState(
      linesToData: this.linesToData, linesFromData: this.linesFromData);  
}

class _LinesLoadingPageState extends State<LinesLoadingPage> {  Map<String, dynamic>? linesToData; Map<String, dynamic>? linesFromData;
  _LinesLoadingPageState({this.linesToData, this.linesFromData});

  final String url = "api.buscloud.ml";
  var linesTo;
  var linesFrom;

  @override
  void initState() {
    super.initState();
  }

  Future<http.Response> getToLines() async {
    var r1 = await http.get(Uri.https(url, "/api/v1/getlinestoschool", linesToData)).timeout(Duration(seconds: 30));
    return r1;
  }

  Future<http.Response> getFromLines() async {
    print(linesFromData);
    var r2 = await http.get(Uri.https(url, "/api/v1/getlinesfromschool", linesFromData)).timeout(Duration(seconds: 30));
    return r2;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("BusCloud"),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            
          },
        ),
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: Future.wait([getToLines(), getFromLines()]),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                
                return Text("Succeded");
              }  
              else {
                	return Center(child: Image(image: AssetImage("assets/bus.gif"),));
              }
            }
          ),
        ],
      ),
    );
  }
}
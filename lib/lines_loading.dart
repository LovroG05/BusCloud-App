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

  Future<dynamic> getAllLines() async {
    return [await getLinesTo(), await getLinesFrom()];
  }

  Future<dynamic> getLinesTo() async {
    var response = await http.get(Uri.https(url, "/api/v1/getlinestoschool", linesToData));
    return response.body;
  }

  Future<dynamic> getLinesFrom() async {
    var response = await http.get(Uri.https(url, "/api/v1/getlinesfromschool", linesFromData));
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: getAllLines(),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.done) {
                print(snapshot.data);
                return Text(snapshot.data.toString());
              }  
              else {
                return CircularProgressIndicator();
              }
            }
          )
        ],
      ),
    );
  }
}
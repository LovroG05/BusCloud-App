import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

class LinesLoadingPage extends StatefulWidget {
  final linesToData;
  final linesFromData;

  const LinesLoadingPage({Key? key, this.linesToData, this.linesFromData})
      : super(key: key);  @override
  _LinesLoadingPageState createState() => _LinesLoadingPageState(
      linesToData: this.linesToData, linesFromData: this.linesFromData);  
}

class _LinesLoadingPageState extends State<LinesLoadingPage> {  var linesToData; var linesFromData;
  _LinesLoadingPageState({this.linesToData, this.linesFromData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
      ),
      body: Column(
        children: [
          
        ],
      ),
    );
  }
}
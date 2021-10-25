import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'components/line_card.dart';
import 'package:toggle_switch/toggle_switch.dart';

class LinesLoadingPage extends StatefulWidget {
  @required final Map<String, dynamic>? linesToData;
  @required final Map<String, dynamic>? linesFromData;
  @required final List<dynamic>? stations;

  const LinesLoadingPage({Key? key, required this.linesToData, required this.linesFromData, required this.stations})
      : super(key: key);  @override
  _LinesLoadingPageState createState() => _LinesLoadingPageState(
      linesToData: this.linesToData, linesFromData: this.linesFromData, stations: this.stations);  
}

class _LinesLoadingPageState extends State<LinesLoadingPage> {  
  Map<String, dynamic>? linesToData; 
  Map<String, dynamic>? linesFromData;
  List<dynamic>? stations;
  _LinesLoadingPageState({this.linesToData, this.linesFromData, this.stations});

  Map<String, dynamic> toSchool = {};
  Map<String, dynamic> fromSchool = {};
  List toLines = [];
  List fromLines = [];


  final String url = "api.buscloud.ml";
  var linesTo;
  var linesFrom;
  int dir = 0; // 0 == school, 1 == home

  @override
  void initState() {
    super.initState();
  }

  Future<http.Response> getToLines() async {
    var r1 = await http.get(Uri.https(url, "/api/v1/getlinestoschool", linesToData)).timeout(Duration(seconds: 30));
    return r1;
  }

  Future<http.Response> getFromLines() async {
    var r2 = await http.get(Uri.https(url, "/api/v1/getlinesfromschool", linesFromData)).timeout(Duration(seconds: 30));
    return r2;
  }

  bool _linesBool() {
    if(dir == 0) {
      return true;
    }
    return false;
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
            builder: (context, AsyncSnapshot<List<http.Response>> snapshot) {
              if(snapshot.hasData) {
                toSchool = json.decode(snapshot.data![0].body);
                fromSchool = json.decode(snapshot.data![1].body);
                toLines = toSchool["lines"];
                fromLines = fromSchool["lines"];
                return Expanded(
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: ToggleSwitch(
                            initialLabelIndex: dir,
                            totalSwitches: 2,
                            activeBgColor: [Theme.of(context).primaryColor],
                            activeFgColor: Colors.white,
                            inactiveBgColor: Colors.grey,
                            inactiveFgColor: Colors.grey[900], 
                            labels: ["School", "Home"],
                            onToggle: (index) {
                              setState(() {
                                dir = index;
                              }); 
                            },
                          ),
                        )
                      ),
                      
                      Visibility(
                        visible: _linesBool(),
                        child: Flexible(
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              padding: EdgeInsets.all(8),
                              itemCount: toLines.length,
                              itemBuilder: (BuildContext context, int index) {
                                return card(toLines[index],
                                            linesToData,
                                            stations
                              );
                            }
                          ),
                        )
                      ),
                      Visibility(
                        visible: !_linesBool(),
                        child: Flexible(
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              padding: EdgeInsets.all(8),
                              itemCount: fromLines.length,
                              itemBuilder: (BuildContext context, int index) {
                                return card(fromLines[index],
                                            linesFromData,
                                            stations
                              );
                            }
                          ),
                        ),
                      ),
                    ],
                  )
                );
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
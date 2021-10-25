import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

String stationName(List<dynamic>? stations, String stationId) {
  String lineName = "station";
  stations?.forEach((element) {
    if(int.parse(element["lineId"]) == int.parse(stationId)) {
      lineName = element["lineName"];
    }
  });
  return lineName;
}

dynamic card(Map<String, dynamic> line, Map<String, dynamic>? linesQueryData, List<dynamic>? stations) {
  List startTime = line["startTime"];
  List arrivalTime = line["arrivalTime"]; 
  return Container(
    child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.directions_bus_filled),
              SizedBox(width: 5),
              Column(
                children: [
                  Text(stationName(stations, linesQueryData!["start_station"]) + ": " + startTime[3].toString() + ":" + startTime[4].toString()),
                  Text(stationName(stations, linesQueryData["end_station"]) + ": " + arrivalTime[3].toString() + ":" + arrivalTime[4].toString())
                ],
              )
            ],
          ),
        )
      ), 
  );
}
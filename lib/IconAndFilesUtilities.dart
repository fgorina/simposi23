import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/config.json');
}

// Get icon by name from assets
// theme 0 -> clar, 1 -> fosc
Image getImage(name) {
  var fullName = "assets/" + name + ".png";
  return Image(image: AssetImage(fullName));
}

Image getSizedImage(name,  width, height) {
  var fullName = "assets/" + name + ".png";
  return Image(image: AssetImage(fullName), width: width, height: height);
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month
        && day == other.day;
  }
}

extension DateRangeFormatting on DateTimeRange {


  String formatted(){
    var formatter = DateFormat('dd/MM/yy HH:mm');
    var formatter1 = DateFormat('HH:mm');
    return start.isSameDate(end) ?
      "de ${formatter.format(start)} a ${formatter1.format(end)}" :
      "de ${formatter.format(start)} a ${formatter.format(end)}"
          ;
  }
}




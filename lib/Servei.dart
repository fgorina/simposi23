import 'package:flutter/material.dart';
import 'DatabaseRecord.dart';

List<Color> colorsProductes = [Colors.pinkAccent, Colors.tealAccent, Colors.amberAccent, Colors.blueAccent,
  Colors.cyanAccent, Colors.deepOrangeAccent, Colors.deepPurpleAccent, Colors.greenAccent, Colors.indigoAccent, Colors.lightBlueAccent, Colors.lightGreenAccent];
List<Color> colorsProductes1 = [Colors.pink, Colors.teal, Colors.amber, Colors.blue,
  Colors.cyan, Colors.deepOrange, Colors.deepPurple, Colors.green, Colors.indigo, Colors.lightBlue, Colors.lightGreen];

class Servei  implements DatabaseRecord{


  @override
  int id;
  @override
  String name;
  DateTimeRange valid;
  String field;
  int idProducte; // 0 si no existeix
  Servei(this.id, this.name, this.valid, this.field, this.idProducte);

  @override
  bool isEqual(DatabaseRecord r){
    if (runtimeType != r.runtimeType){
      return false;
    }
    else{
      var r1 = r as Servei;
      return id == r.id
          && name == r.name
          && valid == r1.valid
      && field == r1.field
        && idProducte == r1.idProducte;
    }
  }

  static Servei fromCSV(String dades){
    var fields = dades.split(";");    // Camps Separats per ;

    int codi = int.parse(fields[0]);
    String nom = fields[1];
    DateTime from = DateTime.parse(fields[2]);
    DateTime to = DateTime.parse(fields[3]);
    DateTimeRange valid = DateTimeRange(start: from, end: to);
    String field = fields[4];
    int producte = int.tryParse(fields[5]) ?? 0;

    return Servei(codi, nom, valid, field, producte);
  }

  String toCSV(){
    return  "$id;$name;${valid.start};${valid.end};$field;$idProducte";
  }

  Map<String, String> toMap(){
    Map<String, String> aMap = {};
    aMap["id"] = id.toString();
    aMap["descripcio"] = name;
    aMap["data_inici"] = valid.start.toString();
    aMap["data_fi"] = valid.end.toString();
    aMap["field"] = field;
    aMap["id_producte"] = idProducte.toString();

    return aMap;

  }
}
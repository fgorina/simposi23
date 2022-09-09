import 'package:flutter/material.dart';
import 'DatabaseRecord.dart';
import 'package:decimal/decimal.dart';

class Producte  implements DatabaseRecord {
  int id;
  String name;
  Decimal preu;

  Producte(this.id, this.name, this.preu);

  bool isEqual(DatabaseRecord r){
    if (this.runtimeType != r.runtimeType){
      return false;
    }
    else{
      var r1 = r as Producte;
      return this.id == r.id
          && this.name == r.name
          && this.preu == r1.preu;
    }
  }

  static Producte fromCSV(String dades){
    var fields = dades.split(";");    // Camps Separats per ;

    int codi = int.parse(fields[0]);
    String nom = fields[1];
    Decimal preu = Decimal.tryParse(fields[2]) ?? Decimal.fromInt(0);
    return Producte(codi, nom, preu);
  }

  String toCSV(){
    return  "$id;$name;${preu}";
  }



}

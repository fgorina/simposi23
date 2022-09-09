import 'DatabaseRecord.dart';
import 'package:decimal/decimal.dart';

class Modalitat  implements DatabaseRecord {
  int id;
  String name;

  Modalitat(this.id, this.name);

  bool isEqual(DatabaseRecord r){
    if (this.runtimeType != r.runtimeType){
      return false;
    }
    else{
      var r1 = r as Modalitat;
      return this.id == r.id
          && this.name == r.name;
    }
  }

  static Modalitat fromCSV(String dades){
    var fields = dades.split(";");    // Camps Separats per ;

    int codi = int.parse(fields[0]);
    String nom = fields[1];
    return Modalitat(codi, nom);
  }

  String toCSV(){
    return  "$id;$name";
  }



}

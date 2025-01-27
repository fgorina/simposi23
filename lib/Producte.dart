import 'DatabaseRecord.dart';
import 'package:decimal/decimal.dart';

class Producte  implements DatabaseRecord {
  @override
  int id;
  @override
  String name;
  Decimal preu;

  Producte(this.id, this.name, this.preu);

  @override
  bool isEqual(DatabaseRecord r){
    if (runtimeType != r.runtimeType){
      return false;
    }
    else{
      var r1 = r as Producte;
      return id == r.id
          && name == r.name
          && preu == r1.preu;
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
    return  "$id;$name;$preu";
  }



}

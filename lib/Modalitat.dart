import 'DatabaseRecord.dart';

class Modalitat  implements DatabaseRecord {
  @override
  int id;
  @override
  String name;

  Modalitat(this.id, this.name);

  @override
  bool isEqual(DatabaseRecord r){
    if (runtimeType != r.runtimeType){
      return false;
    }
    else{
      var r1 = r as Modalitat;
      return id == r.id
          && name == r.name;
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

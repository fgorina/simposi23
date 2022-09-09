import 'DatabaseRecord.dart';


class Compra implements DatabaseRecord{
  int id;
  String name;
  DateTime data;
  int idParticipant;
  int idProducte;
  int terminal;

  Compra(this.id, this.name, this.data, this.idParticipant, this.idProducte, this.terminal);

  bool isEqual(DatabaseRecord r){
    if (this.runtimeType != r.runtimeType){
      return false;
    }
    else{
      var r1 = r as Compra;
      return this.id == r.id
          && this.name == r.name
          && this.data == r1.data
          && this.terminal == r1.terminal;
    }
  }

  static Compra fromCSV(String dades){

    var fields = dades.split(";");    // Camps Separats per ;

    int codi = int.parse(fields[0]);
    DateTime data = DateTime.parse(fields[1]);
    int idParticipant = int.parse(fields[2]);
    int idProducte = int.parse(fields[3]);
    int terminal = int.parse(fields[4]);

    String nom = "$idProducte per $idParticipant";

    return Compra(codi, nom, data, idParticipant, idProducte, terminal);
  }

  String toCSV(){
    return  "$id;$data;$idParticipant;$idProducte;$terminal";
  }

}
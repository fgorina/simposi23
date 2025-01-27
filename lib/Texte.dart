import 'DatabaseRecord.dart';

class Texte  implements DatabaseRecord {
  @override
  int id;
  @override
  String name;
  int id_taula;
  int id_item;
  String idioma;
  String valor;

  Texte(this.id, this.name, this.id_taula, this.id_item, this.idioma, this.valor);

  @override
  bool isEqual(DatabaseRecord r){
    if (runtimeType != r.runtimeType){
      return false;
    }
    else{
      var r1 = r as Texte;
      return id == r.id
          && id_taula == r.id_taula
          && id_item == r1.id_item
          && idioma == r1.idioma;
    }
  }

  static Texte fromCSV(String dades){
    var fields = dades.split(";");    // Camps Separats per ;

    int codi = int.parse(fields[0]);
    String nom = fields[4];
    int idTaula = int.parse(fields[1]);
    int idItem = int.parse(fields[2]);
    String idioma = fields[3];
    String valor = fields[4];


    return Texte(codi, nom, idTaula, idItem, idioma, valor);
  }

  String toCSV(){
    return  "$id;$id_taula;$id_item;$idioma;$valor";
  }

}

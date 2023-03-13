import 'DatabaseRecord.dart';

class Texte  implements DatabaseRecord {
  int id;
  String name;
  int id_taula;
  int id_item;
  String idioma;
  String valor;

  Texte(this.id, this.name, this.id_taula, this.id_item, this.idioma, this.valor);

  bool isEqual(DatabaseRecord r){
    if (this.runtimeType != r.runtimeType){
      return false;
    }
    else{
      var r1 = r as Texte;
      return this.id == r.id
          && this.id_taula == r.id_taula
          && this.id_item == r1.id_item
          && this.idioma == r1.idioma;
    }
  }

  static Texte fromCSV(String dades){
    var fields = dades.split(";");    // Camps Separats per ;

    int codi = int.parse(fields[0]);
    String nom = fields[4];
    int id_taula = int.parse(fields[1]);
    int id_item = int.parse(fields[2]);
    String idioma = fields[3];
    String valor = fields[4];


    return Texte(codi, nom, id_taula, id_item, idioma, valor);
  }

  String toCSV(){
    return  "$id;${id_taula};${id_item};$idioma;$valor";
  }

}

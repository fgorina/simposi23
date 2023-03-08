import 'Servei.dart';
import 'Contractacio.dart';
import 'DatabaseRecord.dart';
import 'Database.dart';

class Participant  implements DatabaseRecord{

  int id;
  String name;
  int modalitat;
  String dataModificat;

  String email;
  String idioma;
  String samarreta;

  bool registrat;
  bool pagat;


  Participant(  this.id,  this.name, this.modalitat,  this.dataModificat, this.email, this.idioma, this.samarreta,  this.registrat, this.pagat);

  List<Contractacio> contractacions(){
     var d = Database.shared;

     return d.searchContractacions(( p0) => (p0 as Contractacio).participantId == this.id);
  }

  @override
  bool isEqual(DatabaseRecord r){
    if (this.runtimeType != r.runtimeType){
      return false;
    }
    else{
      var r1 = r as Participant;
      return this.id == r.id
          && this.name == r.name
          && this.registrat == r1.registrat
          && this.pagat == r1.pagat;

    }
  }
  // Crea un participant a partir de un registre de wpdj_pagaia_qr_sympo2023
  static Participant fromCSV(String dades){
    var fields = dades.split(";");    // Camps Separats per ;


    int codi = int.parse(fields[0]);
    String nom = fields[1];
    int modalitat = int.parse(fields[2]);
    String dataModificat = fields[3];
    String email = fields[4];
    String idioma = fields[5];
    String samarreta = fields[6];


    bool registrat = int.parse(fields[7]) == 1;

    return Participant(codi, nom, modalitat,dataModificat, email, idioma, samarreta, registrat, true);
  }

  String toCSV(){
    return  "$id;$name;$modalitat;$dataModificat;$email;$idioma;$samarreta;${registrat?1:0}";
  }

}
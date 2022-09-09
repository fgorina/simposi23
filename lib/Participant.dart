import 'Servei.dart';
import 'Contractacio.dart';
import 'DatabaseRecord.dart';
import 'Database.dart';

class Participant  implements DatabaseRecord{

  int id;
  String name;
  int modalitat;

  bool esmorzars;
  bool setmana;
  bool esmorzarsSetmana;

  bool registrat;
  bool pagat;

  Participant(  this.id,  this.name, this.modalitat, this.esmorzars, this.setmana, this.esmorzarsSetmana, this.registrat, this.pagat);

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
          && this.esmorzars == r1.esmorzars
          && this.setmana == r1.setmana
          && this.esmorzarsSetmana == r1.esmorzarsSetmana
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
    bool esmorzars = int.parse(fields[4]) != 0;
    bool setmana  = int.parse(fields[15]) != 0;
    bool esmorzarsSetmana = int.parse(fields[7]) != 0;
    bool registrat = int.parse(fields[3]) == 1;

    return Participant(codi, nom, modalitat, esmorzars, setmana, esmorzarsSetmana, registrat, true);
  }

  String toCSV(){
    return  "$id;$name;$modalitat;${registrat?1:0}";
  }

}
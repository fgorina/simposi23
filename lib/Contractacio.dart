import 'DatabaseRecord.dart';

import 'Servei.dart';
import 'Database.dart';

import 'Table.dart';



class Contractacio implements DatabaseRecord{

  int id; // Es codi id_participant * 100 + id_servei
  String name;
  int participantId;
  int  serveiId;
  int  estat;

  Contractacio(this.id, this.name, this.participantId, this.serveiId, this.estat);

  Servei? servei(){
    var d = Database.shared;

    return d.findServei(serveiId);
  }

  @override
  bool isEqual(DatabaseRecord r){
    if (this.runtimeType != r.runtimeType){
      return false;
    }
    else{
      var r1 = r as Contractacio;
      return this.id == r.id
          && this.name == r.name
          && this.participantId == r1.participantId
          && this.serveiId == r1.serveiId
          && this.estat == r1.estat;

    }
  }

  // Crea una llista de contractacions a partir de un registre de wpdj_pagaia_qr_sympo2023
  static List<Contractacio> fromCSV(String dades, Table<Servei> serveis){
    var fields = dades.split(";");    // Camps Separats per ;

    List<Contractacio> contractacions = [];
    int participantId = int.parse(fields[0]);
    for (int i = 4; i < 16; i++){
       int serveiId = i - 3;
      int estat = int.parse(fields[i]);

      Servei? servei = serveis.find(serveiId);

      String nom = servei?.name ?? "Unknown Servei" ;
      contractacions.add(Contractacio(participantId * 100 + serveiId , nom, participantId, serveiId, estat));
      
    }

    return contractacions;
  }



}
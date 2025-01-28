import 'package:flutter/material.dart';
import 'DatabaseRecord.dart';
import 'Servei.dart';
import 'Database.dart';
import 'Table.dart' as t;



class Contractacio implements DatabaseRecord{

  @override
  int id; // Es codi id_participant * 100 + id_servei
  @override
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
    if (runtimeType != r.runtimeType){
      return false;
    }
    else{
      var r1 = r as Contractacio;
      return id == r.id
          && name == r.name
          && participantId == r1.participantId
          && serveiId == r1.serveiId
          && estat == r1.estat;

    }
  }

  // Crea una llista de contractacions a partir de un registre de wpdj_pagaia_qr_sympo2023
  static List<Contractacio> fromCSV(String dades, t.Table<Servei> serveis){
    var fields = dades.split(";");    // Camps Separats per ;

    List<Contractacio> contractacions = [];
    int participantId = int.parse(fields[0]);
    for (int i = 8; i < fields.length-2; i++){
       int serveiId = i - 7;
       int estat = int.parse(fields[i]);

      Servei? servei = serveis.find(serveiId);

      String nom = servei?.name ?? "Unknown Servei" ;
      contractacions.add(Contractacio(participantId * 100 + serveiId , nom, participantId, serveiId, estat));
      
    }

    return contractacions;
  }

  DateTimeRange valid(Database d){
    return d.findServei(serveiId)!.valid;
  }



}
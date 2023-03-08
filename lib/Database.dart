import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simposi23/BacklogListWidget.dart';
import 'dart:io';
import 'DatabaseRecord.dart';
import 'Table.dart' as t;
import 'Participant.dart';
import 'Servei.dart';
import 'Contractacio.dart';
import 'Producte.dart';
import 'Compra.dart';
import 'Server.dart';
import 'package:http/http.dart' as http;
import 'Modalitat.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import "SlideRoutes.dart";
import 'BacklogListWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:decimal/decimal.dart';

bool debugging = true;
Future showBacklog(BuildContext cnt) async {
  await Navigator.push(cnt, SlideLeftRoute(widget: BacklogListWidget()));
}

Map reverseMap(Map map) {
  Map map1 = Map();

  map.forEach((key, value) {
    map1[value] = key;
  });
  return map1;
}

enum TipusOperacions {
  productes,
  serveis,
  participants,
  registrar,
  consumir,
  comprar,
  compres,
  modalitats
}

Map<TipusOperacions, String> stringOperacio = {
  TipusOperacions.productes: "productes",
  TipusOperacions.serveis: "serveis",
  TipusOperacions.participants: "participants",
  TipusOperacions.registrar: "registrar",
  TipusOperacions.consumir: "consumir",
  TipusOperacions.comprar: "comprar",
  TipusOperacions.compres: "compres",
  TipusOperacions.modalitats: "modalitats",
};

Map<String, TipusOperacions> operacioString =
    reverseMap(stringOperacio) as Map<String, TipusOperacions>;

class Operacio {
  TipusOperacions op;
  int _id;

  Operacio(this.op, this._id);

  String idValue() {
    if (_id == -1) {
      return "";
    } else {
      return _id.toString();
    }
  }

  int id() {
    if (_id == -1) {
      return -1;
    } else {
      return _id;
    }
  }

  bool isEqual(Operacio r) {
    return op == r.op && _id == r._id;
  }

  String toCSV() {
    return stringOperacio[op]! + ";" + id.toString();
  }

  static Operacio fromCSV(String s) {
    var data = s.split(";");
    return Operacio(operacioString[data[0]]!, int.parse(data[1]));
  }
}

final List<IconData> numberIcons = [
  Icons.filter_1,
  Icons.filter_2,
  Icons.filter_3,
  Icons.filter_4,
  Icons.filter_5,
  Icons.filter_6,
  Icons.filter_7,
  Icons.filter_8,
  Icons.filter_9,
  Icons.filter_9_plus,
];

class Database {
  static final Database shared = Database._constructor();

// Manage subscriptions
  
  bool initialized = false;

  List subscriptors = [];

  List<Operacio> _backlog = [];
  bool _processingBacklog =
      false; // So we don't execute simultaneusly many _procesaBacklog

  final Map<String, t.Table<DatabaseRecord>> _tables =
      Map<String, t.Table<DatabaseRecord>>();

  List<Participant> selectedParticipants = [];
  Participant? currentParticipant;
  List<Contractacio> currentContractacions = [];

  Server server = Server(Protocol.https, "simposium.pagaia.club", "wp-content/simposi23.php");  // 192.168.1.18
  int terminal = 1;

  String lastServerError = "";

  Database._constructor() {
    _init();
  }

  Database(List<t.Table<DatabaseRecord>> tables) {
    tables.forEach((element) {
      _tables[element.name] = element;
    });
  }

  void _init() async {
    _tables['Participants'] =
        t.Table<Participant>('Participants', Map<int, Participant>());
    _tables['Serveis'] = t.Table<Servei>('Serveis', Map<int, Servei>());
    _tables['Contractacions'] =
        t.Table<Contractacio>('Contractacions', Map<int, Contractacio>());
    _tables['Productes'] = t.Table<Producte>('Productes', Map<int, Producte>());
    _tables['Compres'] = t.Table<Compra>('Compres', Map<int, Compra>());
    _tables['Modalitats'] =
        t.Table<Modalitat>('Modalitats', Map<int, Modalitat>());

    try {
      await loadServerCofiguration();

      await loadData();
      if (server.host.isNotEmpty) {
        await loadDataFromServer(true);

      }
    }catch(e){

    }
    initialized = true;
    notifySubscriptors("OK", "", "initialized");
  }

  Future setServerAddress(Protocol protocol, String host, String path) async {
    server.setAddress(protocol, host, path);
    await saveServerConfiguration();
    await  loadDataFromServer(true);
  }

  Future saveServerConfiguration() async{
    if (kIsWeb){
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('protocol', server.protocol == Protocol.https ? 1 : 0);
      await prefs.setString('host', server.host);
      await prefs.setString('url', server.url);
      await prefs.setInt('terminal', terminal);
      print(server.url);

    } else {
      var dir = (await getApplicationDocumentsDirectory()).path;
      var path = dir + "/Config.csv";
      var file = File(path);

      String s = server.protocol == Protocol.https ? "https" : "http" + ";" +
          server.host + ";" + server.url + ";" + terminal.toString();

      await file.writeAsString(s, flush: true);
    }

  }

  Future loadServerCofiguration() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();

      server.protocol = (prefs.getInt('protocol') ?? 0) == 1 ? Protocol.https : Protocol.http;
      server.host = prefs.getString('host') ?? "";
      server.url = prefs.getString('url') ?? "";
      terminal = prefs.getInt('terminal') ?? 1;
      print(server.url);
    } else {
      var dir = (await getApplicationDocumentsDirectory()).path;
      var path = dir + "/Config.csv";
      var file = File(path);

      try {
        var strData = await file.readAsString();
        var data = strData.split(";");

        if (data.length >= 3) {
          await setServerAddress(
              data[0] == "https" ? Protocol.https : Protocol.http, data[1],
              data[2]);
        }
        if(data.length > 4){
          terminal = int.tryParse(data[3]) ?? 1;
        }else {
          terminal = 1;
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  // Subscriptions

  // Subscriptions and notifications

  void addSubscriptor(object) {
    if (!subscriptors.contains(object)) {
      subscriptors.add(object);
    }
  }

  void removeSubscriptors(
    object,
  ) {
    if (subscriptors.contains(object)) {
      subscriptors.remove(object);
    }
  }

  void notifySubscriptors(String status, String message, String op) {
    for (var object in subscriptors) {
      object.modelUpdated(status, message, op);
    }
  }


  // Auxiliar

  String nameForCompra(Compra compra) {
    Participant? participant = findParticipant(compra.idParticipant);
    Producte? producte = findProducte(compra.idProducte);

    DateFormat formatter = DateFormat("dd/MM/yy");

    return "Compra " +
        (producte?.name ?? "") +
        " per " +
        (participant?.name ?? "") +
        " el " +
        formatter.format(compra.data);
  }

  // BACKLOG

  void addToBacklog(Operacio op, {bool allowDuplicates = false}) {
    if (allowDuplicates) {
      _backlog.add(op);
      saveBacklog();
      return;
    } else {
      try {
        var x = _backlog.firstWhere(((element) => element.isEqual(op)));
      } catch (e) {
        _backlog.add(op);
        saveBacklog();
      }
    }
  }

  int backLogCount() {
    return _backlog.length;
  }

  List<Operacio> allBacklog() {
    return _backlog;
  }

  Future procesaBacklog() async {
    _procesaBacklog();
  }

  Future _procesaBacklog() async {
    if (_processingBacklog) {
      return;
    }

    _processingBacklog = true;

    int i = _backlog.length;

    try {
      while (_backlog.length > 0 && i > 0) {
        Operacio op = _backlog[0];


        switch (op.op) {
          case TipusOperacions.productes:
            await server.getData(stringOperacio[TipusOperacions.productes]!,
                op.idValue(), terminal, (List<String> response){ _updateProductes(response, clear: op.idValue().isEmpty);});
            break;

          case TipusOperacions.serveis:
            await server.getData(stringOperacio[TipusOperacions.serveis]!,
                op.idValue(),   terminal, (List<String> response){_updateServeis(response, clear: op.idValue().isEmpty);});
            break;

          case TipusOperacions.participants:
            await server.getData(stringOperacio[TipusOperacions.participants]!,
                op.idValue(),   terminal, (List<String> response){_updateParticipants(response, clear: op.idValue().isEmpty);});
            break;

          case TipusOperacions.registrar:
            await server.getData(stringOperacio[TipusOperacions.registrar]!,
                op.idValue(),   terminal, (List<String> response){_updateParticipants(response, clear: op.idValue().isEmpty);});
            break;

          case TipusOperacions.consumir:
            await server.getData(stringOperacio[TipusOperacions.consumir]!,
                op.idValue(),   terminal, (List<String> response){_updateContractacio(response, clear: op.idValue().isEmpty);});
            break;

          case TipusOperacions.comprar:
            await server.getData(stringOperacio[TipusOperacions.comprar]!,
                op.idValue(),   terminal, (List<String> response){_updateContractacio(response, clear: op.idValue().isEmpty);});
            break;

          case TipusOperacions.compres:
            await server.getData(stringOperacio[TipusOperacions.compres]!,
                op.idValue(),  terminal, (List<String> response){ _updateCompres(response, clear: op.idValue().isEmpty);});
            break;

          case TipusOperacions.modalitats:
            await server.getData(stringOperacio[TipusOperacions.modalitats]!,
                op.idValue(),  terminal, (List<String> response){ _updateModalitats(response, clear: op.idValue().isEmpty);});
            break;

          default:
            break;
        }
        i--;
        _backlog.removeAt(0);
        lastServerError = "";
        notifySubscriptors("OK", lastServerError, "");
      }
    } catch (e, stacktrace) {
      print("Error in Backlog\n" + e.toString() + "\n" + stacktrace.toString());
      lastServerError = e.toString();
      notifySubscriptors("OK", lastServerError, "");
    }

    saveBacklog();
    notifySubscriptors("OK", lastServerError, "");
    _processingBacklog = false;
  }

  // Server connection

  Future _updateParticipants(List<String> response, {autosave = true, clear = false}) async {
    var status = response[0];
    var op = response[1];
    var data = response.sublist(2);

    if (status == "OK") {
      if(clear) {
        _tables['Participants']!.clear();
        _tables['Contractacions']!.clear();

      }

      for (var row in data) {
        if (row.isNotEmpty) {
          Participant p = Participant.fromCSV(row);
          _tables['Participants']!.addAll([p] as List<Participant>);

          // Now update contractacions
          List<Contractacio> contractacions =
              Contractacio.fromCSV(row, _tables['Serveis'] as t.Table<Servei>);
          _tables['Contractacions']!
              .addAll(contractacions as List<Contractacio>);
        }
      }

      if (autosave) {
        saveData();
      }
    }

    notifySubscriptors(status, data[0], op);
  }

  Future _updateContractacio(List<String> response, {autosave = true, clear = false}) async {
    var status = response[0];
    var op = response[1];
    var data = response.sublist(2);

    if (status == "OK") {
      if(clear) {
        _tables['Participants']!.clear();
        _tables['Contractacions']!.clear();

      }

      var row = data[0];
      if (row.isNotEmpty) {
        Participant p = Participant.fromCSV(row);
        _tables['Participants']!.addAll([p] as List<Participant>);

        // Now update contractacions
        List<Contractacio> contractacions =
            Contractacio.fromCSV(row, _tables['Serveis'] as t.Table<Servei>);
        _tables['Contractacions']!.addAll(contractacions as List<Contractacio>);
        currentParticipant = p;
        currentContractacions = contractacions;
      }
      if (autosave) {
        saveData();
      }
    } else {
      if(clear) {
        _tables['Participants']!.clear();
        _tables['Contractacions']!.clear();

      }

      if (data.length >= 2) {
        var row = data[1];
        if (row.isNotEmpty) {

          Participant p = Participant.fromCSV(row);
          _tables['Participants']!.addAll([p] as List<Participant>);

          // Now update contractacions
          List<Contractacio> contractacions =
              Contractacio.fromCSV(row, _tables['Serveis'] as t.Table<Servei>);
          _tables['Contractacions']!
              .addAll(contractacions);

          currentParticipant = p;
          currentContractacions = contractacions;
        }
        if (autosave) {
          saveData();
        }
      }
    }
    notifySubscriptors(status, data[0], op);
  }

  Future _updateServeis(List<String> response, {autosave = true, clear = false}) async {
    var status = response[0];

    var op = response[1];
    var data = response.sublist(2);

    if (status == "OK") {

      if(clear) {
        _tables['Serveis']!.clear();
      }

      for (var row in data) {
        if (row.isNotEmpty) {
          Servei p = Servei.fromCSV(row);
          _tables['Serveis']!.addAll([p] as List<Servei>);
        }
      }
      if (autosave) {
        saveData();
      }
    }
    notifySubscriptors(status, data[0], op);
  }

  Future _updateProductes(List<String> response, {autosave = true, clear = false}) async {
    var status = response[0];
    var op = response[1];
    var data = response.sublist(2);

    if (status == "OK") {

      if(clear) {
        _tables['Productes']!.clear();
      }

      for (var row in data) {
        if (row.isNotEmpty) {
          Producte p = Producte.fromCSV(row);
          _tables['Productes']!.addAll([p] as List<Producte>);
        }
      }
      if (autosave) {
        saveData();
      }
    }
    notifySubscriptors(status, data[0], op);
  }

  Future _updateCompres(List<String> response, {autosave = true, clear = false}) async {
    var status = response[0];
    var op = response[1];
    var data = response.sublist(2);

    if (status == "OK") {

      if(clear) {
        _tables['Compres']!.clear();
      }

      for (var row in data) {
        if (row.isNotEmpty) {
          Compra compra = Compra.fromCSV(row);
          compra.name = nameForCompra(compra);

          _tables['Compres']!.addAll([compra] as List<Compra>);
        }
      }
      if (autosave) {
        saveData();
      }
    }
    notifySubscriptors(status, data[0], op);
  }

  Future _updateModalitats(List<String> response, {autosave: true, clear: false}) async {
    var status = response[0];
    var op = response[1];
    var data = response.sublist(2);

    if (status == "OK") {
      if(clear) {
        _tables['Modalitats']!.clear();
      }

      for (var row in data) {
        if (row.isNotEmpty) {
          Modalitat modalitat = Modalitat.fromCSV(row);

          _tables['Modalitats']!.addAll([modalitat] as List<Modalitat>);
        }
      }
      if (autosave) {
        saveData();
      }
    }
    notifySubscriptors(status, data[0], op);
  }

  Future<bool> loadDataFromServer(bool includeServeis) async {
    bool failed = false;

    if (includeServeis) {
      try {
        await server.getData(
            stringOperacio[TipusOperacions.productes]!, "",  terminal, (List<String> response) {_updateProductes(response, clear: true);});
        lastServerError = "";
      }  on http.ClientException catch (e) {
        failed = true;
        addToBacklog(Operacio(TipusOperacions.productes, -1));
        lastServerError = e.toString() + "\n" + e.message;
      }
      try {
        await server.getData(
            stringOperacio[TipusOperacions.serveis]!, "",  terminal, (List<String> response) { _updateServeis(response, clear: true);});
        lastServerError = "";
      } on http.ClientException catch (e) {
        failed = true;
        addToBacklog(Operacio(TipusOperacions.serveis, -1));
        lastServerError = e.toString() + "\n" + e.message;
      }
        try {
          await server.getData(
              stringOperacio[TipusOperacions.modalitats]!, "",  terminal, (List<String> response) { _updateModalitats(response, clear: true);});
          lastServerError = "";
        }on http.ClientException  catch (e) {
          failed = true;
          addToBacklog(Operacio(TipusOperacions.modalitats, -1));
          lastServerError = e.toString() + "\n" + e.message;
        }
      }

    try {
       await server.getData(stringOperacio[TipusOperacions.participants]!, "", terminal,
           (List<String> response) {_updateParticipants(response, clear: true);});
      lastServerError = "";
      _procesaBacklog();
    } on http.ClientException catch (e) {
      failed = true;
      addToBacklog(Operacio(TipusOperacions.participants, -1));
      lastServerError = e.toString() + "\n" + e.message;
    }

    if (failed) {
      //loadData();
    }

    await loadCompres();

    notifySubscriptors("OK", lastServerError, "");
    return failed;
  }

  Future<bool> loadCompres() async {
    bool failed = false;
    try {
       await server.getData(
          stringOperacio[TipusOperacions.compres]!, "",  terminal, (List<String> response) {_updateCompres(response, clear:true);});
      lastServerError = "";
    } on http.ClientException catch (e) {

      if (kIsWeb){    // Web does not have local storage.
        return true;
      }
      failed = true;
      addToBacklog(Operacio(TipusOperacions.compres, -1));
      lastServerError = e.toString() + "\n" + e.message;
      try {

        var dir = (await getApplicationDocumentsDirectory()).path;
        var path = dir + "/Compres.csv";
        var file = File(path);
        var compresData = await file.readAsString();
        await _updateCompres(compresData.split("\n"), autosave: false, clear: true);
      } catch (e) {
        print("Error loading Compres.csv ${e.toString()}");
      }
    }
    notifySubscriptors("OK", lastServerError, "");
    return failed;
  }

  Future updateParticipant(int id) async {
    try {
      await server.getData(stringOperacio[TipusOperacions.participants]!,
          id.toString(),  terminal, _updateParticipants);
      lastServerError = "";
      _procesaBacklog();
    } on http.ClientException catch (e) {
      lastServerError = e.toString();
      addToBacklog(Operacio(TipusOperacions.participants, id));
      notifySubscriptors("OK", lastServerError, "");
     }
  }

  Future registrarParticipant(int id) async {

    Participant? participant = findParticipant(id);
    if (participant == null) {
      notifySubscriptors("ERROR",
          "El participant amb id $id no hi es a la base de dades.", "registrar");
      return;
    }

    try {

      await server.getData(stringOperacio[TipusOperacions.registrar]!,
          id.toString(),  terminal, _updateParticipants);
      _procesaBacklog();

    } on http.ClientException catch (e) {   // Proces Local

      if (participant.registrat) {
        notifySubscriptors(
            "ERROR", "{$participant.name} ja està registrat!", "registrar");

        return;
      }
      participant.registrat = true;
      saveData();
      notifySubscriptors("OK", "", "registrar");


      lastServerError = e.toString();
      notifySubscriptors("OK", lastServerError, "");
      addToBacklog(Operacio(TipusOperacions.registrar, id));
    }
  }

  Future consumir(int id) async {
    // Some checks so things are fast although the conexion is not available:
    int idParticipant = (id / 100).floor();
    int idServei = id % 100;

    Servei? servei = findServei(idServei);
    Participant? participant = findParticipant(idParticipant);

    if (participant == null) {
      notifySubscriptors(
          "ERROR",
          "El participant amb id $idParticipant no hi es a la base de dades.",
          "consumir");
      return;
    }

    String nom = participant.name;

    if (servei == null) {
      notifySubscriptors(
          "ERROR",
          "El servei amb id $idServei no hi es a la base de dades.",
          "consumir");
      return;
    }

    String nomServei = servei.name;

    Contractacio? contractacio = findContractacio(id);

    if (contractacio == null) {
      notifySubscriptors(
          "ERROR", "No hi ha registre de $nomServei per a $nom", "consumir");
      return;
    }

    try {
      await server.getData("consumir", id.toString(),  terminal, _updateContractacio);
      lastServerError = "";
      _procesaBacklog();
    }   on http.ClientException catch (e) {   //Procés local si la conexió no es correcta

      if (kIsWeb){    // Web does not have local storage.
        lastServerError = e.toString();
        return;
      }

      if (!participant.registrat) {
        notifySubscriptors(
            "ERRORR", " $nom encara NO està registrat ", "consumir");
        return;
      }

      if (contractacio.estat == 0) {
        notifySubscriptors(
            "ERRORP", " $nom NO te pagat $nomServei ", "consumir");
        return;
      }

      if (contractacio.estat == 2) {
        notifySubscriptors(
            "ERROR", " $nom ja ha consumit $nomServei ", "consumir");
        return;
      }


      contractacio.estat = 2;
      saveData();

      lastServerError = e.toString();
      notifySubscriptors("OK", "", "consumir");
      notifySubscriptors("OK", lastServerError, "");
      addToBacklog(Operacio(TipusOperacions.consumir, id),
          allowDuplicates: true);
    }
  }

  Future comprar(int id) async {
    // Falta procés local

    int idParticipant = (id / 100).floor();
    int idProducte = id % 100;

    Producte? producte = findProducte(idProducte);
    Participant? participant = findParticipant(idParticipant);

    if (participant == null) {
      notifySubscriptors(
          "ERROR",
          "El participant amb id $idParticipant no hi es a la base de dades.",
          "comprar");
      return;
    }

    String nom = participant.name;

    if (producte == null) {
      notifySubscriptors(
          "ERROR",
          "El producte amb id $idProducte no hi es a la base de dades.",
          "comprar");
      return;
    }

    String nomProducte = producte.name;
    var compra = findCompra(id);

    if (findCompra(id) != null) {
      notifySubscriptors("ERROR",
          "El producte $nomProducte ja ha estat comprat per $nom.", "comprar");
      return;
    }

    try {
      await server.getData(stringOperacio[TipusOperacions.comprar]!,
          id.toString(),  terminal, _updateContractacio);

      await server.getData(
          stringOperacio[TipusOperacions.compres]!, "",  terminal, _updateCompres);
    }on http.ClientException catch (e) {

      if (kIsWeb){    // Web does not have local storage.
        lastServerError = e.toString();
        return;
      }

      // Aqui fem el process local en cas que no hagi sigut possible parlar amb el servidor

      if (!participant.registrat) {
        notifySubscriptors(
            "ERRORR", " $nom encara NO està registrat ", "comprar");
        return;
      }

      var serveis = searchServeisProducte(producte);

      serveis.forEach((servei) {
        int idContractacio = (idParticipant * 100) + servei.id;
        Contractacio? contractacio = findContractacio(idContractacio);
        if (contractacio != null) {
          if (contractacio.estat == 0) {
            // Si ja esta consumit no es pot tornar a comprar (crec)
            contractacio.estat = 1;
          }
        }
      });

      if (findCompra(id) == null) {
        // Add to compres si no existia ja
        Compra cpr =
            Compra(id, "", DateTime.now(), idParticipant, idProducte, 1);
        cpr.name = nameForCompra(cpr);

        _tables["Compres"]!.addAll([cpr] as List<Compra>);
      }

      saveData();
      lastServerError = e.toString();
      notifySubscriptors("OK", lastServerError, "");
      addToBacklog(Operacio(TipusOperacions.comprar, id));
      addToBacklog(Operacio(TipusOperacions.compres, -1));
    }
  }

  // MAINTENANCE SERVEIS I PRODUCTES

  Future updateServei(Servei servei) async {
    await server.postData("serveis", servei.id.toString(), terminal, servei.toMap(),
        _updateServeis);
  }

  Future deleteServei(Servei servei) async {
    await server.deleteData("serveis", servei.id.toString(), terminal, (p0){
      var status = p0[0];

      if(status == "OK"){
        _tables['Serveis']!.delete(servei);
        saveData();
        notifySubscriptors(status, p0[1], 'serveis');
      }
    });
  }

  //CSV Conversion
  // Genera un registre de participants a partir de Participant + Contratacions

  String paticipantCSV(Participant p) {
    List<Contractacio> contractacions = p.contractacions();

    String s = p.toCSV();
    contractacions.sort((a, b) => a.id.compareTo(b.id));

    for (Contractacio c in contractacions) {
      s = "$s;" + c.estat.toString();
    }

    return s;
  }

  String participantsToCSV(List<Participant> participants) {
    String s = participants.map((e) => paticipantCSV(e)).join("\n");
    return "OK\nparticipantsn\n$s";
  }

  String serveisToCSV(List<Servei> serveis) {
    String s = serveis.map((e) => e.toCSV()).join("\n");
    return "OK\nserveis\n$s";
    return s;
  }

  String productesToCSV(List<Producte> productes) {
    String s = productes.map((e) => e.toCSV()).join("\n");
    return "OK\nproductes\n$s";
    return s;
  }

  String compresToCSV(List<Compra> compres) {
    String s = compres.map((e) => e.toCSV()).join("\n");
    return "OK\ncompres\n$s";
    return s;
  }

  String modalitatsToCSV(List<Modalitat> modalitats) {
    String s = modalitats.map((e) => e.toCSV()).join("\n");
    return "OK\nmodalitats\n$s";
    return s;
  }

  // Saving a revocering data locally

  Future<String> pathFor(String table) async{

    if (kIsWeb){
      return "";
    }

    var check = table.replaceAll("share", "");
    if (_tables[check] == null){
      throw Exception("Table $table not defined in database");
    }
    final String dir = (await getApplicationDocumentsDirectory()).path;
    return "$dir/$table.csv";
  }

  // Salva Serveis i Participants als fitxers Serveis.csv i Participants.csv
  Future saveData() async {

    if (kIsWeb){    // Web does not have local storage.
      return;
    }

    var file = File(await pathFor("Serveis"));
    await file.writeAsString(serveisToCSV(allServeis()), flush: true);

    file = File(await pathFor("Productes"));
    await file.writeAsString(productesToCSV(allProductes()), flush: true);

    file = File(await pathFor("Participants"));
    await file.writeAsString(participantsToCSV(allParticipants()), flush: true);

    file = File(await pathFor("Compres"));
    await file.writeAsString(compresToCSV(allCompres()), flush: true);

    file = File(await pathFor("Modalitats"));
    await file.writeAsString(modalitatsToCSV(allModalitats()), flush: true);
  }

// Llegeix  Serveis i Participants dels fitxers Serveis.csv i Participants.csv i genera Contractacions
  Future loadData() async {

    if (kIsWeb){    // Web does not have local storage.
      return;
    }
    var dir = (await getApplicationDocumentsDirectory()).path;

    try {
      var path = dir + "/Productes.csv";
      var file = File(path);
      var productesData = await file.readAsString();
       await _updateProductes(productesData.split("\n"), autosave: false, clear: true);
    } catch (e) {
      print("Error loading Productes.csv ${e.toString()}");
    }

    try {
      var path = dir + "/Serveis.csv";
      var file = File(path);
      var serveisData = await file.readAsString();
      await _updateServeis(serveisData.split("\n"), autosave: false, clear: true);
    } catch (e) {
      print("Error loading Serveis.csv ${e.toString()}");
    }
    try {
      var path = dir + "/Participants.csv";
      var file = File(path);
      var participantsData = await file.readAsString();
       await _updateParticipants(participantsData.split("\n"), autosave: false, clear: true);
    } catch (e) {
      print("Error loading Participants.csv ${e.toString()}");
    }
    try {
      var path = dir + "/Compres.csv";
      var file = File(path);
      var compresData = await file.readAsString();
      await _updateCompres(compresData.split("\n"), autosave: false, clear: true);
    } catch (e) {
      print("Error loading Compres.csv ${e.toString()}");
    }

    try {
      var path = dir + "/Modalitats.csv";
      var file = File(path);
      var modalitatsData = await file.readAsString();
      await _updateModalitats(modalitatsData.split("\n"), autosave: false, clear: true);
    } catch (e) {
      print("Error loading Modalitats.csv ${e.toString()}");
    }

    try {
      loadBacklog();
    } catch (e) {
      print("Error loading Backlog.csv ${e.toString()}");
    }
  }

  Future saveBacklog() async {
    if(kIsWeb){
      return;
    }
    final String dir = (await getApplicationDocumentsDirectory()).path;
    var path = dir + "/Backlog.csv";
    var file = File(path);

    String s = _backlog.map((e) => e.toCSV()).join("\n");
    await file.writeAsString(s, flush: true);
  }

  Future loadBacklog() async {
    if(kIsWeb){
      return;
    }
    try {
      var dir = (await getApplicationDocumentsDirectory()).path;
      var path = dir + "/Backlog.csv";
      var file = File(path);

      var backlogData = (await file.readAsString()).split("\n");
      _backlog.clear();
      for (var lin in backlogData) {
        _backlog.add(Operacio.fromCSV(lin));
      }
    } catch (e) {}
  }

  // Share data. Fa el join per exportar dades inteligibles per tothom

  String shareCompresData() {

    var compres = allCompres();
    compres.sort(
            (Compra a, Compra b){
          return a.data.compareTo(b.data);
        }
    );

    var titles = "id;Data;id Participant;id Producte;Terminal;Nom Participant;Nom Prodcte;Preu";
    return titles + "\n" + compres.map((compra) {

      Participant? participant = findParticipant(compra.idParticipant);
      Producte? producte = findProducte(compra.idProducte);

      String output = compra.toCSV();
      if(participant != null){
        output = output + ";" + participant.name;
      }else {
        output = output + ";";
      }

      if(producte != null){
        output = output + ";" + producte.name + ";" + producte.preu.toString();
      }else {
        output = output + ";;0.0";
      }
      return output;
    }).join("\n");


  }


  String paticipantCSVShare(Participant p) {
    List<Contractacio> contractacions = p.contractacions();

    String s = p.toCSV();
    contractacions.sort((a, b) => a.id.compareTo(b.id));

    for (Contractacio c in contractacions) {
      s = "$s;" + c.estat.toString();
    }

    return s;
  }
  String shareParticipantsData(){
    var titles = "id;Nom;Modalitat;Registrat;";

    var serveis = allServeis();
    serveis.sort(
        (a, b) => a.id.compareTo(b.id)
    );

    titles += (serveis.map((e) => e.name ).join(";")) + ";Modalitat";
    var participants = allParticipants();

    return titles + "\n" +  participants.map((participant) {
      var output = paticipantCSVShare(participant);
      var modalitat = findModalitat(participant.modalitat);
      if(modalitat != null) {
        output += ";${modalitat.name}";
      }else{
        output += ";";
      }
      return output;
    }).join("\n");

  }


  // Funcions específiques

  DatabaseRecord? find(String table, int id) {
    var tab = _tables[table];
    if (tab != null) {
      return tab.find(id);
    } else {
      return null;
    }
  }

  Participant? findParticipant(int id) {
    var tab = _tables['Participants'];
    if (tab != null) {
      var e = tab.find(id);
      if (e != null) {
        return e as Participant;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Servei? findServei(int id) {
    var tab = _tables['Serveis'];
    if (tab != null) {
      return tab.find(id) as Servei?;
    } else {
      return null;
    }
  }

  Producte? findProducte(int id) {
    var tab = _tables['Productes'];
    if (tab != null) {
      return tab.find(id) as Producte?;
    } else {
      return null;
    }
  }

  Contractacio? findContractacio(int id) {
    var tab = _tables['Contractacions'];
    if (tab != null) {
      return tab.find(id) as Contractacio?;
    } else {
      return null;
    }
  }

  Compra? findCompra(int id) {
    var tab = _tables['Compres'];
    if (tab != null) {
      return tab.find(id) as Compra?;
    } else {
      return null;
    }
  }

  Modalitat? findModalitat(int id) {
    var tab = _tables['Modalitats'];
    if (tab != null) {
      return tab.find(id) as Modalitat?;
    } else {
      return null;
    }
  }

  List<DatabaseRecord> search(String table, bool Function(DatabaseRecord) f) {
    var tab = _tables[table];
    if (tab != null) {
      return tab.search(f);
    } else {
      return [];
    }
  }

  List<Participant> searchParticipants(bool Function(DatabaseRecord) f) {
    var tab = _tables['Participants'];
    if (tab != null) {
      return tab.search(f) as List<Participant>;
    } else {
      return [];
    }
  }

  List<Compra> searchCompres(bool Function(DatabaseRecord) f) {
    var tab = _tables['Compres'];
    if (tab != null) {
      return tab.search(f) as List<Compra>;
    } else {
      return [];
    }
  }

  List<Servei> searchServeis(bool Function(DatabaseRecord) f) {
    var tab = _tables['Serveis'];
    if (tab != null) {
      return tab.search(f) as List<Servei>;
    } else {
      return [];
    }
  }

  List<Servei> searchServeisProducte(Producte p) {
    t.Table<Servei> tab = _tables['Serveis'] as t.Table<Servei>;
    if (tab != null) {
      return tab.search((s) => s.idProducte == p.id) as List<Servei>;
    } else {
      return [];
    }
  }

  List<Contractacio> searchContractacions(bool Function(DatabaseRecord) f) {
    var tab = _tables['Contractacions'];
    if (tab != null) {
      return tab.search(f) as List<Contractacio>;
    } else {
      return [];
    }
  }

  List<Contractacio> searchContractacionsParticipant(Participant p) {
    t.Table<Contractacio> tab =
        _tables['Contractacions'] as t.Table<Contractacio>;
    if (tab != null) {
      return tab.search((c) => c.participantId == p.id) as List<Contractacio>;
    } else {
      return [];
    }
  }

  List<Participant> allParticipants() {
    return _tables['Participants']!.all() as List<Participant>;
  }

  List<Servei> allServeis() {
    return _tables['Serveis']!.all() as List<Servei>;
  }

  List<Producte> allProductes() {
    return _tables['Productes']!.all() as List<Producte>;
  }

  List<Compra> allCompres() {
    return _tables['Compres']!.all() as List<Compra>;
  }

  Map<int, Decimal> compresByTerminal(){

    var result = Map<int, Decimal>();
    var ordered = allCompres();


    ordered.forEach((compra) {

      var producte = findProducte(compra.idProducte);
      if (producte == null){
        return;
      }

      var acum = result[compra.terminal] ?? Decimal.zero;
      var value = acum + producte.preu;

      result[compra.terminal] = value;
     });

    return result;
  }

  List<Modalitat> allModalitats() {
    return _tables['Modalitats']!.all() as List<Modalitat>;
  }

  Producte? findProducteServei(Servei servei) {
    if (servei.idProducte == 0) {
      return null;
    }
    return findProducte(servei.idProducte);
  }

  int countServeis() {
    return _tables['Serveis']!.count();
  }

  int countCompres() {
    return _tables['Compres']!.count();
  }
}

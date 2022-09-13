import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Participant.dart';
import 'Database.dart';
import 'Servei.dart';
import 'Producte.dart';
import 'Contractacio.dart';
import 'screensize_reducers.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:simposi23/LabeledSwitch.dart';
import 'dart:math';
import 'Modalitat.dart';
import 'ComprarWidget.dart';
import 'SlideRoutes.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:intl/intl.dart';

class ParticipantViewWidget extends StatefulWidget {
  final String title = "Participants";

  @override
  _ParticipantViewWidgetState createState() => _ParticipantViewWidgetState();
}

class _ParticipantViewWidgetState extends State<ParticipantViewWidget> {
  Database d = Database.shared;

  List<Widget> stateIcons = [];

  DateFormat df = DateFormat("dd/MM");

  void initState() {
    super.initState();
    stateIcons = [
      Icon(
        Icons.no_accounts,
        color: d.currentParticipant!.registrat ? Colors.red : Colors.pink,
      ),
      Icon(
        Icons.check_circle_outline,
        color: d.currentParticipant!.registrat ? Colors.green : Colors.pink,
      ),
      Icon(
        Icons.check_circle,
        color: Colors.red,
      )
    ];
    d.addSubscriptor(this);
    d.updateParticipant(d.currentParticipant!.id);
  }

  void dispose() {
    d.removeSubscriptors(this);
    super.dispose();
  }

  void modelUpdated(String status, String message, String op) {
    final _isTopOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;

    if (status != "OK" && _isTopOfNavigationStack) {
      Database.displayAlert(context, "STOP", message);
    }

    if (_isTopOfNavigationStack) {
      setState(() {
        d.currentParticipant = d.findParticipant(d.currentParticipant!.id);
        d.currentContractacions = d.currentParticipant!.contractacions();
      });
    }
  }

  void registrar() async {
    int id = d.currentParticipant!.id;
    await d.registrarParticipant(id);

    setState(() {
      d.currentParticipant = d.findParticipant(id);
      d.selectedParticipants.removeWhere((p) => p.id == id);
    });
  }

  void showError() {
    Database.displayAlert(context, "Error de Connexió", d.lastServerError);
  }

  void consumir(int index) {
    int id = d.currentContractacions[index].id;
    d.consumir(id);
  }

  Future comprar(Contractacio contractacio) async {
    var servei = d.findServei(contractacio.serveiId);
    if (servei == null) {
      return;
    }
    var producte = d.findProducteServei(servei);
    if (producte == null) {
      return;
    }

    var participant = d.findParticipant(contractacio.participantId);
    if (participant != null) {
      await Navigator.push(context,
          SlideLeftRoute(widget: ComprarWidget(participant, producte)));
      setState(() {});
    }
  }

  Widget buildTile(Participant p, Producte pr) {
    var serveis = d.searchServeisProducte(pr);
    serveis.sort((a, b) => a.id.compareTo(b.id));

    var contractacions = d.searchContractacionsParticipant(p).where((element) {
      var servei = d.findServei(element.serveiId)!;
      return servei.idProducte == pr.id;
    }).toList();


    print("${pr.name} $contractacions");
    contractacions.sort((a, b) => a.id.compareTo(b.id));

    List<Widget> icons = contractacions.map((contractacio) {
      return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(df.format(contractacio.valid(d).start)),
        IconButton(
          icon: stateIcons[contractacio.estat],
          onPressed: (contractacio.estat == 0 && p.registrat)
              ? () {
                  comprar(contractacio);
                }
              : null,
        ),
      ]);
    }).toList();

    return ListTile(
        //tileColor: colorsProductes[pr.id % colorsProductes.length],
        title: Text(pr.name),
        subtitle: Row(
            mainAxisAlignment: icons.length == 1 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
            children: icons));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = [];
    int c = min(d.backLogCount(), 10);
    if (c > 0) {
      icons.add(Icon(
        numberIcons[c - 1],
        color: Colors.red,
      ));
    }

    if (d.lastServerError.isNotEmpty) {
      icons.add(IconButton(
          icon: const Icon(Icons.warning_amber, color: Colors.red),
          onPressed: showError));
    }

    Modalitat? modalitat = d.findModalitat(d.currentParticipant!.modalitat);
    String modalitatName =
        modalitat?.name ?? d.currentParticipant!.modalitat.toString();

    ScrollController controller = ScrollController();

    return KeyboardSizeProvider(
      smallSize: 500.0,
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(d.currentParticipant!.name),

          actions: icons,
        ),
        body: Consumer<ScreenHeight>(builder: (context, _res, child) {
          return SafeArea(
            minimum: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: Column(
              children: [
                Text(modalitatName,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Container(height: 10),
                d.currentParticipant!.registrat
                    ? Text("")
                    : ElevatedButton(
                        onPressed: () {
                          registrar();
                        },
                        child: Text("Registrar",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.pinkAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.black)))),

                /*labeledSwitch("Esmorzars", d.currentParticipant!.esmorzars ,  null, enabled: false),
                labeledSwitch("Setmana Paleig", d.currentParticipant!.setmana,  null, enabled: false),
                d.currentParticipant!.pagat ?
                labeledSwitch("Pagat", d.currentParticipant!.pagat ,  null, enabled: false) :
                Text("No Pagat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.red)),

                 */
                Text(""),
                Container(
                  height: screenHeight(context) - 353,
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: controller,
                    child: ListView.separated(
                        controller: controller,
                        itemCount: d.allProductes().length,
                        itemBuilder: (BuildContext context, int index) {
                          return buildTile(
                              d.currentParticipant!, d.allProductes()[index]);
                        },
                    separatorBuilder: (BuildContext context, int index) {
                          return Divider(color: Colors.grey);
                    },
                        ),
                  ),
                ),
                Spacer(),
                Container(
                  width: 100,
                  height: 100,
                  child: BarcodeWidget(
                      data: d.paticipantCSV(d.currentParticipant!),
                      barcode: Barcode.qrCode()),
                ),
                Spacer(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Participant.dart';
import 'Database.dart';
import 'Servei.dart';
import 'Contractacio.dart';
import 'screensize_reducers.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:simposi23/LabeledSwitch.dart';
import 'dart:math';
import 'Modalitat.dart';
import 'ComprarWidget.dart';
import 'SlideRoutes.dart';

class ParticipantViewWidget extends StatefulWidget {
  final String title = "Participants";

  @override
  _ParticipantViewWidgetState createState() => _ParticipantViewWidgetState();
}

class _ParticipantViewWidgetState extends State<ParticipantViewWidget> {
  Database d = Database.shared;

  void initState() {
    super.initState();
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
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    List<Widget> stateIcons = [
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
                Text(""),
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
                            shape:
                                RoundedRectangleBorder(
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
                  height: screenHeight(context) - 250,
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: ScrollController(),
                    child: ListView.builder(
                        itemCount: d.currentContractacions.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(d.currentContractacions[index].name),
                            trailing: IconButton(
                              icon: stateIcons[
                                  d.currentContractacions[index].estat],
                              onPressed: (d.currentContractacions[index]
                                              .estat ==
                                          0 &&
                                      d.currentParticipant!.registrat)
                                  ? () {
                                      comprar(d.currentContractacions[index]);
                                    }
                                  : null,
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

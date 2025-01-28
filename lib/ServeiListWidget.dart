import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simposi23/ParticipantsListWidget.dart';
import 'dart:math';
import 'Database.dart';
import 'Servei.dart';
import 'Participant.dart';

import 'SlideRoutes.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'IconAndFilesUtilities.dart';
import 'Contractacio.dart';
import 'ServeiView.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'Alerts.dart';

class ServeiListWidget extends StatefulWidget {
  const ServeiListWidget({super.key});

  @override
  _ServeiListWidgetState createState() => _ServeiListWidgetState();
}

class _ServeiListWidgetState extends State<ServeiListWidget> {
  TextEditingController controller = TextEditingController();

  Database d = Database.shared;

  Servei? elServei;

  @override
  void initState() {
    super.initState();
    d.addSubscriptor(this);
  }

  @override
  void dispose() {
    d.removeSubscriptors(this);
    super.dispose();
  }

  void modelUpdated(String status, String message, String op) {
    final isTopOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;

    if (status != "OK" && isTopOfNavigationStack) {
      //Database.displayAlert(context, "Error in List", message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    if (isTopOfNavigationStack) {
      setState(() {


      });
    }
  }

  void showError() {
    Alerts.displayAlert(context, "Error de Connexió", d.lastServerError);
  }

  Widget buildTile(Servei servei, int index) {
    // Get number of participants which has payed and number which have already consumed

    var payed = d
        .searchContractacions((p0) =>
            (p0 as Contractacio).estat > 0 &&
            (p0).serveiId == servei.id)
        .length;

    var toServe = d.searchContractacions((p0) {
      var p = d.findParticipant((p0 as Contractacio).participantId);
      if (p == null || p.registrat != 1) {
        return false;
      }
      return (p0).estat > 0 &&
          (p0).serveiId == servei.id;
    }).length;
    var vegs = d.searchContractacions((p0) {
      var p = d.findParticipant((p0 as Contractacio).participantId);
      if (p == null || p.registrat != 1 || !p.veg) {
        return false;
      }
      return (p0).estat > 0 &&
          (p0).serveiId == servei.id;
    }).length;
    var normal = toServe - vegs;
    var consumed = d
        .searchContractacions((p0) =>
            (p0 as Contractacio).estat == 2 &&
            (p0).serveiId == servei.id)
        .length;
    var consumedVegs =  d
        .searchContractacions((p0) {
      var p = d.findParticipant((p0 as Contractacio).participantId);
      if (p == null || !p.veg) {
        return false;
      }
      return (p0 as Contractacio).estat == 2 &&
        (p0).serveiId == servei.id;
      }) .length;


    return Slidable(
      // Specify a key if the Slidable is dismissible.
      key: const ValueKey(0),

      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            // An action can be bigger than the others.
            flex: 2,
            onPressed: (context) async {
              if (await Alerts.yesNoAlert(context, "Confirmació",
                      "Esteu segur que voleu esborrar ${servei.name}") ??
                  false) {
                    await d.deleteServei(servei);
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: CupertinoIcons.delete,
            label: 'Esborrar',
          ),
        ],
      ),

      child: ListTile(
        tileColor:
            colorsProductes1[servei.idProducte % colorsProductes1.length],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              servei.name,
            ),
            Text("($normal V: $vegs)/$payed" , style: TextStyle(fontSize: 14),) // Text("$toServe/$payed")
          ],
        ),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(servei.valid.formatted()),
              LinearPercentIndicator(
                lineHeight: 20,
                leading: Text(consumed.toString()),
                trailing: Text(toServe.toString()),
                percent: toServe > 0 ? consumed / toServe : 0,
                backgroundColor:
                    colorsProductes[servei.idProducte % colorsProductes.length],
              ),
            ]),
        onLongPress: () async {
          print("Opening servei");
          await Navigator.push(
              context, SlideLeftRoute(widget: ServeiView(servei)));
          setState(() {});
        },
        onTap:() async {
          print("Listing participants del servei");
          d.selectedParticipants = d.searchParticipants((p0) {
            Participant p1 = p0 as Participant;
            List<Contractacio> l = d.searchContractacionsParticipant(p0).where((cont) => cont.serveiId == servei.id && cont.estat != 0).toList();
            int x = l.length;
            return p1.registrat == 1 && x != 0;
          });



          d.currentParticipant = null;
          d.currentContractacions = [];
          await Navigator.push(
          context, SlideLeftRoute(widget: ParticipantsListWidget(false, servei.id, false, false)));
          setState(() {});
        }

      ),
    );
  }

  Future addServei() async {
    DateTimeRange valid =
        DateTimeRange(start: DateTime.now(), end: DateTime.now());
    var servei = Servei(0, "Nou Servei", valid, "", 1);
    await Navigator.push(context, SlideLeftRoute(widget: ServeiView(servei)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = [];
    int c = min(d.backLogCount(), 10);
    if (c > 0) {
      icons.add(IconButton(
          icon: Icon(numberIcons[c - 1]),
          color: Colors.red,
          onPressed: () async {
            await showBacklog(context);
            setState(() {});
          }));
    }

    if (d.lastServerError.isNotEmpty) {
      icons.add(IconButton(
          icon: const Icon(Icons.warning_amber),
          color: Colors.red,
          onPressed: showError));
    }

    icons.add(IconButton(
        icon: const Icon(CupertinoIcons.add_circled), onPressed: addServei));

    return KeyboardSizeProvider(
      smallSize: 500.0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Serveis"),
          actions: icons,
        ),
        body: Consumer<ScreenHeight>(builder: (context, res, child) {
          return SafeArea(
            minimum: const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: ListView.separated(
              itemCount: d.countServeis(),
              itemBuilder: (BuildContext context, int index) {
                return buildTile(d.allServeis()[index], index);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  color: Colors.grey,
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

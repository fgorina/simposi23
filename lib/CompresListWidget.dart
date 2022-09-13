import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'Database.dart';
import 'Compra.dart';
import "Participant.dart";
import 'Producte.dart';
import 'SlideRoutes.dart';
import 'screensize_reducers.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'IconAndFilesUtilities.dart';
import 'package:intl/intl.dart';

class CompresListWidget extends StatefulWidget {
  @override
  _CompresListWidgetState createState() => _CompresListWidgetState();
}

class _CompresListWidgetState extends State<CompresListWidget> {
  TextEditingController controller = TextEditingController();

  Database d = Database.shared;

  List<Compra> compres = [];

  void initState() {
    super.initState();
    d.addSubscriptor(this);
    compres = d.allCompres();
    compres.sort(
        (Compra a, Compra b){
          return a.data.compareTo(b.data);
        }
    );

    d.loadCompres();

  }

  void dispose() {
    d.removeSubscriptors(this);
    super.dispose();
  }

  void modelUpdated(String status, String message, String op) {
    final _isTopOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;

    if (status != "OK" && _isTopOfNavigationStack) {
      Database.displayAlert(context, "Error in Compres List", message);
    }
    if (_isTopOfNavigationStack) {
      setState(() {
        compres = d.allCompres();
        compres.sort(
                (Compra a, Compra b){
              return a.data.compareTo(b.data)*-1;
            }
        );

      });
    }
  }

  void showError() {
    Database.displayAlert(context, "Error de Connexió", d.lastServerError);
  }

  Widget compraWidget(Compra compra, int index) {
    DateFormat formatter = DateFormat("dd/MM/yy");
    Participant? participant = d.findParticipant(compra.idParticipant);
    String nomParticipant = participant?.name ?? "";
    Producte? producte = d.findProducte(compra.idProducte);
    String nomProducte = producte?.name ?? "";
    String preu = (producte?.preu ?? Decimal.fromInt(0)).toString() + " €";

    return ListTile(
      tileColor: [Colors.black12, Colors.white][index % 2],
      title: Row(children: [
        Container(
            width: screenWidth(context) - 110,
            child: Text(formatter.format(compra.data) + " " + nomProducte)),
        Container(
            width: 35,
            child: Text(
              preu,
              textAlign: TextAlign.end,
            )),
      ]),
      subtitle: Text(nomParticipant),
      onTap: () {},
    );
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

    Decimal total = Decimal.fromInt(0);

    d.allCompres().forEach((element) {
      Producte? producte = d.findProducte(element.idProducte);
      total = total + (producte?.preu ?? Decimal.fromInt(0));
    });

    if (d.lastServerError.isNotEmpty) {
      icons.add(IconButton(
          icon: const Icon(Icons.warning_amber),
          color: Colors.red,
          onPressed: showError));
    }

    ScrollController controller = ScrollController();

    return KeyboardSizeProvider(
      smallSize: 500.0,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Compres"),
          actions: icons,
        ),
        body: Consumer<ScreenHeight>(builder: (context, _res, child) {
          return SafeArea(
            minimum: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(
                    total.toString() + " € ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.end,
                  )
                ],
              ),
              Container(height: 20),
              Container(
                height: screenHeight(context) - 200,

                child: Scrollbar(
                  thumbVisibility: true,
                  controller: controller,
                  child: ListView.builder(
                    itemCount: compres.length,
                    itemBuilder: (BuildContext context, int index) {
                      return compraWidget(compres[index], index);
                    },
                    controller: controller,
                    shrinkWrap: true,

                  ),

          ),
              ),


            ]),
          );
        }),
      ),
    );
  }
}

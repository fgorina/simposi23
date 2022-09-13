import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'Database.dart';
import 'Servei.dart';
import 'SlideRoutes.dart';
import 'screensize_reducers.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';


class BacklogListWidget extends StatefulWidget {
  @override
  _BacklogListWidgetState createState() => _BacklogListWidgetState();
}

class _BacklogListWidgetState extends State<BacklogListWidget> {
  TextEditingController controller = TextEditingController();

  Database d = Database.shared;

  void initState() {
    super.initState();
    d.addSubscriptor(this);
  }

  void dispose() {
    d.removeSubscriptors(this);
    super.dispose();
  }

  void modelUpdated(String status, String message, String op) {
    final _isTopOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;

    if (status != "OK" && _isTopOfNavigationStack) {
      //Database.displayAlert(context, "Error in List", message);
    }
    if (_isTopOfNavigationStack) {
      setState(() {

      });
    }
  }

  String idToString(Operacio op){


      switch(op.op){

        case TipusOperacions.participants:
            return d.findParticipant(op.id())?.name ?? "";
            break;

        case TipusOperacions.productes:
          return d.findProducte(op.id())?.name ?? "";
          break;

        case TipusOperacions.serveis:
          return d.findServei(op.id())?.name ?? "";
          break;

        case TipusOperacions.consumir:
          int idp = (op.id() / 100).floor();
          int ids = op.id() % 100;
          String who = d.findParticipant(idp)?.name ?? "";
          String what =  d.findServei(ids)?.name ?? "";

          return "$what per  $who";
          break;

        case TipusOperacions.comprar:

          int idp = (op.id() / 100).floor();
          int ids = op.id() % 100;
          String who = d.findParticipant(idp)?.name ?? "";
          String what =  d.findProducte(ids)?.name ?? "";

          return "$what per $who";
          break;

        default:
          return op.idValue();
          break;

      }

  }
  void showError() {
    Database.displayAlert(context, "Error de Connexió", d.lastServerError);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = [];
    int c = min(d.backLogCount(), 10);
    if (c > 0) {
      icons.add(IconButton(icon: Icon(numberIcons[c-1]), color: Colors.red, onPressed: (){d.procesaBacklog();}));
    }

    if (d.lastServerError.isNotEmpty) {
      icons.add(IconButton(
          icon: const Icon(Icons.warning_amber),
          color: Colors.red,
          onPressed: showError));
    }

    return KeyboardSizeProvider(
      smallSize: 500.0,
      child: Scaffold(
        appBar: AppBar(
          title: Text("BackLog Op's"),
          actions: icons,
        ),
        body: Consumer<ScreenHeight>(builder: (context, _res, child) {
          return SafeArea(
            minimum: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: ListView.builder(
              itemCount: d.backLogCount(),
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  tileColor : [Colors.black12, Colors.white][index % 2],
                  title: Text(
                    d.allBacklog()[index].op.toString() + "(" + d.allBacklog()[index].idValue() + ")" ,
                  ),
                  subtitle: Text(
                      idToString(d.allBacklog()[index]),
                  ),
                  onTap: () {},
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

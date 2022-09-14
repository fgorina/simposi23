import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'Database.dart';
import 'Servei.dart';

import 'SlideRoutes.dart';
import 'screensize_reducers.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'IconAndFilesUtilities.dart';
import 'Contractacio.dart';


class ServeiListWidget extends StatefulWidget {
  @override
  _ServeiListWidgetState createState() => _ServeiListWidgetState();
}

class _ServeiListWidgetState extends State<ServeiListWidget> {
  TextEditingController controller = TextEditingController();

  Database d = Database.shared;

  Servei? elServei;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    if (_isTopOfNavigationStack) {}
  }

  void showError() {
    Database.displayAlert(context, "Error de Connexió", d.lastServerError);
  }

  Widget buildTile(Servei servei, int index){

    // Get number of participants which has payed and number which have already consumed

    var payed = d.searchContractacions((p0) => (p0 as Contractacio).estat > 0 && (p0 as Contractacio).serveiId == servei.id).length;
    var consumed = d.searchContractacions((p0) => (p0 as Contractacio).estat == 2 && (p0 as Contractacio).serveiId == servei.id).length;
    return ListTile(
      tileColor : colorsProductes1[servei.idProducte % colorsProductes1.length],
      title: Text(
        servei.name,
      ),
      subtitle: Text(servei.valid.formatted() + "\nConsumit $consumed de $payed" ),
      onTap: () {},
    );


  }

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = [];
    int c = min(d.backLogCount(), 10);
    if (c > 0) {

      icons.add(IconButton(icon: Icon(numberIcons[c-1]), color: Colors.red, onPressed: () async {
        await showBacklog(context);
        setState(() {

        });
      }));
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
          title: Text("Serveis"),
          actions: icons,
        ),
        body: Consumer<ScreenHeight>(builder: (context, _res, child) {
          return SafeArea(
            minimum: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: ListView.separated(
              itemCount: d.countServeis(),
              itemBuilder: (BuildContext context, int index) {
                return buildTile(d.allServeis()[index], index);
              },
              separatorBuilder: (BuildContext context, int index) {
                   return Divider(color: Colors.grey,);
          },
            ),
          );
        }),
      ),
    );
  }
}

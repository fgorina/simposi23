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
      Database.displayAlert(context, "Error in List", message);
    }
    if (_isTopOfNavigationStack) {}
  }

  void showError() {
    Database.displayAlert(context, "Error de Connexió", d.lastServerError);
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
            child: ListView.builder(
              itemCount: d.countServeis(),
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  tileColor : [Colors.black12, Colors.white][index % 2],
                  title: Text(
                    d.allServeis()[index].name,
                  ),
                  subtitle: Text(d.allServeis()[index].valid.formatted() + "  " + d.allServeis()[index].idProducte.toString() ),
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

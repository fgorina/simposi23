import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';import 'Participant.dart';
import 'screensize_reducers.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'dart:math';
import 'IconAndFilesUtilities.dart';

import 'Database.dart';
import 'Participant.dart';
import 'Servei.dart';
import 'Producte.dart';

class ComprarWidget extends StatefulWidget {

  Participant participant;
  Producte producte;

  String status ="";
  String message = "";

  ComprarWidget(this.participant, this.producte);

  @override
  _ComprarWidgetState createState() => _ComprarWidgetState();

}

class _ComprarWidgetState extends State<ComprarWidget> {

  Database d = Database.shared;
  List<Servei> serveis = [];


  void initState() {
    super.initState();
    d.addSubscriptor(this);
    serveis = d.searchServeisProducte(widget.producte);
    // Load services


  }

  void dispose() {
    d.removeSubscriptors(this);
    super.dispose();
  }

  void modelUpdated(String status, String message, String op){
    if (op == "comprar") {
      widget.status = status;
      widget.message = message;
    }

    setState(() {
    });

  }
  void showError(){
    Database.displayAlert(context, "Error de Connexió", d.lastServerError);
  }


  @override
  Widget build(BuildContext context) {

    List<Widget> icons = [];
    int c = min(d.backLogCount(), 10);
    if (c > 0 ){
      icons.add(IconButton(icon: Icon(numberIcons[c-1]), color: Colors.red, onPressed: () async {
        await showBacklog(context);
        setState(() {

        });
      }));
    }

    if(d.lastServerError.isNotEmpty){
      icons.add(IconButton(icon: const Icon(Icons.warning_amber, color: Colors.red), onPressed: showError));
    }



    return KeyboardSizeProvider(
      smallSize: 500.0,
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Comprar"),
          actions:  icons,

        ),
        body: Consumer<ScreenHeight>(builder: (context, _res, child) {
          return SafeArea(
            minimum: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Text("Comprar " + widget.producte.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black)),

                  Text("Per a " + widget.participant.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                  Container(height: 40,),

                  Text("Preu : " + widget.producte.preu.toString() + " €", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: Colors.black)),

                  Container(height: 40,),
                  Text("Serveis inclosos: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                  Container(height: 20,),
                  Container(
                    alignment: Alignment.center,
                      height: 100,
                      width: 300,
                      child: ListView(children: serveis.map((e) => Text(e.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 18))).toList() ),
                    decoration: BoxDecoration(border: Border.all(width: 2)),
                  ),
                  Container(height: 40,),
                  ElevatedButton(onPressed: () async {
                    int id = widget.participant.id * 100 + widget.producte.id;

                    await d.comprar(id);
                    Navigator.pop(context);
                  },
                      child: Text("Comprar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white30,
                          shape:
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.black)
                          )
                      )),




                  Spacer(),
                  Text(widget.status + " " + widget.message),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

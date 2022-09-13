import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';import 'Participant.dart';
import 'Database.dart';
import 'screensize_reducers.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'Participant.dart';
import 'Servei.dart';
import 'Contractacio.dart';
import 'dart:math';
import 'IconAndFilesUtilities.dart';
import 'SlideRoutes.dart';
import 'ComprarWidget.dart';

class RespostaWidget extends StatefulWidget {

  Participant participant;
  Servei servei;

  String status ="";
  String message = "";

  RespostaWidget(this.participant, this.servei,  this.status, this.message);


  @override
  _RespostaWidgetState createState() => _RespostaWidgetState();
}

class _RespostaWidgetState extends State<RespostaWidget> {


  Database d = Database.shared;

  Image si = getImage("si");
  Image no = getImage("no");

  void initState() {
    super.initState();
    d.addSubscriptor(this);
    int id = widget.participant.id * 100 + widget.servei.id;
    print("Consumint $id");
    d.consumir(id);
  }

  void dispose() {
    d.removeSubscriptors(this);
    super.dispose();
  }

  void modelUpdated(String status, String message, String op){
    if (op == "consumir") {
      widget.status = status;
      widget.message = message;
    }

    setState(() {
    });

   }
  void showError(){
    Database.displayAlert(context, "Error de Connexió", d.lastServerError);
  }

  Future comprar (Participant participant, Servei servei) async{

    var producte = d.findProducteServei(servei);

    if (producte != null){
      await Navigator.push(context, SlideLeftRoute(widget:ComprarWidget(participant, producte)));

      // Ara reintentem l¡'operació qu esperem sigui positiva si hem comprat

      int id = widget.participant.id * 100 + widget.servei.id;

      d.consumir(id);

    }

  }

  Future registrar(Participant participant) async {
    await d.registrarParticipant(participant.id);
    int id = widget.participant.id * 100 + widget.servei.id;

    d.consumir(id);

  }

  Widget actionWidget(){

    // Error NO registrat. Oferir l'opció de registrar ara!!!

    if (widget.status == "ERRORR"){
      return ElevatedButton(onPressed: (){
        registrar(widget.participant);
      },
          child: Text("Registrar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              primary: Colors.white30,
              shape:
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black)
              )
          ));
    }
  // No comprat. Podem comprar

    if(widget.status == "ERRORP" && widget.servei.idProducte != 0 ) {
      return ElevatedButton(onPressed: () {
        comprar(widget.participant, widget.servei);
      },
          child: Text("Comprar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              primary: Colors.white30,
              shape:
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black)
              )
          ));
    }
    // Tot OK

      return Text("");

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
          title: Text(widget.servei.name),
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


                Text(widget.participant.name, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black)),
                Spacer(),
                widget.status == "OK" ? si : no,
                Spacer(),
                Text(widget.status == "OK" ? "" : widget.message, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                Spacer(),
                actionWidget() ,
                Spacer(),
              ],
            ),
            ),
          );
        }),
      ),
    );
  }
}
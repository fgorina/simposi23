import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'Database.dart';
import 'Compra.dart';
import "Participant.dart";
import 'Producte.dart';
import 'screensize_reducers.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class CompresListWidget extends StatefulWidget {
  @override
  _CompresListWidgetState createState() => _CompresListWidgetState();
}

class _CompresListWidgetState extends State<CompresListWidget> {

  List<Color> colorsTerminals = [Colors.pinkAccent, Colors.tealAccent, Colors.amberAccent, Colors.blueAccent,
    Colors.cyanAccent, Colors.deepOrangeAccent, Colors.deepPurpleAccent, Colors.greenAccent, Colors.indigoAccent, Colors.lightBlueAccent, Colors.lightGreenAccent];
  TextEditingController controller = TextEditingController();

  Database d = Database.shared;

  List<Compra> compres = [];

  bool resum = false;

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
      //Database.displayAlert(context, "Error in Compres List", message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
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

  void shareCompres() async {
    var data = d.shareCompresData();

    // Save it to a file. That way we may share to Numbers directly
    var path = await d.pathFor("shareCompres");
    var file = File(path);
    await file.writeAsString(data, flush: true);

    var result = await Share.shareFilesWithResult([path]);

  }

  Widget resumWidget(int terminal, Decimal amount, int index){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text("Terminal " + terminal.toString()), Text(amount.toString()),],
    );


  }

  Widget compraWidget(Compra compra, int index) {
    DateFormat formatter = DateFormat("dd/MM/yy");
    Participant? participant = d.findParticipant(compra.idParticipant);
    String nomParticipant = participant?.name ?? "";
    Producte? producte = d.findProducte(compra.idProducte);
    String nomProducte = producte?.name ?? "";
    String preu = (producte?.preu ?? Decimal.fromInt(0)).toString() + " €";

    return ListTile(
      tileColor: colorsTerminals[compra.terminal % colorsTerminals.length],
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

  Widget buildResum(BuildContext context){

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

    var compresTerminal = d.compresByTerminal();
    var keys = compresTerminal.keys.toList();
    keys.sort((k1, k2)=>k1.compareTo(k2));


    if (d.lastServerError.isNotEmpty) {
      icons.add(IconButton(
          icon: const Icon(Icons.warning_amber),
          color: Colors.red,
          onPressed: showError));
    }

    if(kIsWeb ||!Platform.isAndroid){
      icons.add(  CupertinoSwitch(onChanged: (value){setState(() {
        resum = value;
      });}, value:resum));

    }else {
      icons.add( Switch(onChanged: (value) {
        setState(() {
          resum = value;
        });
      }, value: resum));
    }


    icons.add (IconButton(
        icon:  Icon((kIsWeb || !Platform.isAndroid) ? CupertinoIcons.share : Icons.share ),
        onPressed: shareCompres));

    ScrollController controller = ScrollController();

    return KeyboardSizeProvider(
      smallSize: 500.0,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Compres per Terminal"),
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
                  child: ListView.separated(
                    itemCount: keys.length,
                    itemBuilder: (BuildContext context, int index) {
                      return resumWidget(keys[index], compresTerminal[keys[index]] ?? Decimal.zero, index);
                    },
                    separatorBuilder: (context, index) {return Divider(color: Colors.white30,);},
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

  Widget buildDetail(BuildContext context) {
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

    if(kIsWeb ||!Platform.isAndroid){
      icons.add(  CupertinoSwitch(onChanged: (value){setState(() {
        resum = value;
      });}, value:resum));

    }else {
      icons.add( Switch(onChanged: (value) {
        setState(() {
          resum = value;
        });
      }, value: resum));
    }


    icons.add (IconButton(
        icon:  Icon((kIsWeb || !Platform.isAndroid) ? CupertinoIcons.share : Icons.share ),
        onPressed: shareCompres));



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
                  child: ListView.separated(
                    itemCount: compres.length,
                    itemBuilder: (BuildContext context, int index) {
                      return compraWidget(compres[index], index);
                    },
                    separatorBuilder: (context, index) {return Divider(color: Colors.white30,);},
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
@override
  Widget build(BuildContext context) {
    if(resum){
      return buildResum(context);
    }else{
      return buildDetail(context);
    }

  }
}

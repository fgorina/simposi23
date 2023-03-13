import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Participant.dart';
import 'Database.dart';
import 'Producte.dart';
import 'Contractacio.dart';
import 'screensize_reducers.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'dart:math';
import 'dart:io';
import 'Modalitat.dart';
import 'Alerts.dart';
import 'ComprarWidget.dart';
import 'SlideRoutes.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SendEmailView extends StatefulWidget {
  final String title = "Participants";

  @override
  _SendEmailViewState createState() => _SendEmailViewState();
}

class _SendEmailViewState extends State<SendEmailView> {
  Database db = Database.shared;
  List<bool> selected =
      Database.shared.allModalitats().map((e) => false).toList() as List<bool>;
  bool sending = false;
  int itemToSend = 0;

  List<Participant> targets = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Enviament de missatges"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 40),
            Text(
              "Seleccioneu els destinataris",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(height: 40),
            Row(children: [
              Spacer(),
              Container(
                width: 250,
                padding: EdgeInsets.all(0),
                child: ToggleButtons(
                    isSelected: selected,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor: Colors.lightBlue,
                    selectedColor: Colors.white,
                    fillColor: Colors.lightBlueAccent,
                    children: db.allModalitats().map((m) {
                      return Text(m.name);
                    }).toList(),
                    direction: Axis.vertical,
                    onPressed: (int index) {
                      setState(() {
                        selected[index] = !selected[index];
                      });
                    }),
              ),
              Spacer()
            ]),
            Spacer(),
            sending && targets.length > 0 && targets.length > itemToSend
                ?Container(
                width: 250, child: LinearProgressIndicator(
                    value: itemToSend / targets.length,
                    semanticsLabel: 'Linear progress indicator',
                  ))
                : SizedBox.shrink(),
            Spacer(),
            CupertinoButton(
                child: Text(
                  "Enviar",
                  style: TextStyle(color: Colors.white),
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
                onPressed: () {
                  targets = db.searchParticipants((p) {
                    var pr = p as Participant;
                    var m = p.modalitat;
                    return selected[m];
                  });
                  sending = true;
                  itemToSend = 0;
                  final  server = gmail(db.smtpUser, db.smtpPassword);

                  targets.forEach((element) async {
                      await element.sendPdf(server: server);
                    setState(() {
                      itemToSend += 1;
                      print("Enviat missatge per a  ${element.name}");
                    });
                  });
                }),
            Spacer()
          ],
        ),
      ),
    );
  }
}

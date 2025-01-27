import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Participant.dart';
import 'Database.dart';
import 'package:mailer/smtp_server.dart';

class SendEmailView extends StatefulWidget {
  final String title = "Participants";

  const SendEmailView({super.key});

  @override
  _SendEmailViewState createState() => _SendEmailViewState();
}

class _SendEmailViewState extends State<SendEmailView> {
  Database db = Database.shared;
  List<bool> selected =
      Database.shared.allModalitats().map((e) => false).toList();
  bool sending = false;
  int itemToSend = 0;

  List<Participant> targets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Enviament de missatges"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 40),
            const Text(
              "Seleccioneu els destinataris",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(height: 40),
            Row(children: [
              const Spacer(),
              Container(
                width: 250,
                padding: const EdgeInsets.all(0),
                child: ToggleButtons(
                    isSelected: selected,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor: Colors.lightBlue,
                    selectedColor: Colors.white,
                    fillColor: Colors.lightBlueAccent,
                    direction: Axis.vertical,
                    onPressed: (int index) {
                      setState(() {
                        selected[index] = !selected[index];
                      });
                    },
                    children: db.allModalitats().map((m) {
                      return Text(m.name);
                    }).toList()),
              ),
              const Spacer()
            ]),
            const Spacer(),
            sending && targets.isNotEmpty && targets.length > itemToSend
                ? SizedBox(
                    width: 250,
                    child: LinearProgressIndicator(
                      value: itemToSend / targets.length,
                      semanticsLabel: 'Linear progress indicator',
                    ))
                : const SizedBox.shrink(),
            const Spacer(),
            CupertinoButton(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
                onPressed: () async {
                  targets = db.searchParticipants((p) {
                    var pr = p as Participant;
                    var m = p.modalitat;
                    return selected[m] && !pr.pagat;
                  });
                  sending = true;
                  itemToSend = 0;
                  final server = gmail(db.smtpUser, db.smtpPassword);

                  for (int i = 0; i < targets.length; i++) {
                    var element = targets[i];
                    await element.sendPdf(server: server, test: false);
                    setState(() {
                      itemToSend += 1;
                      print("Enviat missatge per a  ${element.name}");
                    });
                    //await Future.delayed(const Duration(milliseconds: 500), () {});
                  }
                },
                child: const Text(
                  "Enviar",
                  style: TextStyle(color: Colors.white),
                )),
            const Spacer()
          ],
        ),
      ),
    );
  }
}

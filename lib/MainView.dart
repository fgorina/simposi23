
import 'package:flutter/material.dart';

import 'package:simposi23/CompresListWidget.dart';
import "SlideRoutes.dart";
import 'ParticipantsListWidget.dart';
import 'Database.dart';
import 'Participant.dart';
import 'Servei.dart';
import 'ServeiListWidget.dart';
import 'dart:math';
import 'SettingsView.dart';
import 'Alerts.dart';
import 'SendEmailView.dart';



class MainView extends StatefulWidget {
  const MainView({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with WidgetsBindingObserver {
  Database database = Database.shared;
  String answerStatus = "";
  String answerOp = "";
  List<String> returnedData = [];

  int terminal = 1;

  bool admin = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && database.server.host.isNotEmpty) {
      database.loadDataFromServer(true);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    database.addSubscriptor(this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    database.removeSubscriptors(this);
    super.dispose();
  }

  void modelUpdated(String status, String message, String op) {
    final isTopOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;

    if (status != "OK" && isTopOfNavigationStack) {
      //Database.displayAlert(context, "ERROR in main", message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      setState(() {});
    }

    print("MainView isTopOfNavigationStack $isTopOfNavigationStack");
    if (isTopOfNavigationStack || true) {
      setState(() {});
    }
  }

  void gotoParticipants() async {
    database.selectedParticipants = database.searchParticipants((p0) => true);
    database.currentParticipant = null;
    database.currentContractacions = [];

    await Navigator.push(
        context, SlideLeftRoute(widget: ParticipantsListWidget(true, 0, true, true)));
    setState(() {});
  }

  void gotoRegistre() async {
    database.selectedParticipants = database.searchParticipants((p0) {
      Participant p1 = p0 as Participant;
      return p1.registrat == 0;
    });
    database.currentParticipant = null;
    database.currentContractacions = [];

    await Navigator.push(
        context, SlideLeftRoute(widget: ParticipantsListWidget(false, 0, true, true)));
    setState(() {});
  }

  void gotoServei(int id) async {
    database.selectedParticipants = database.searchParticipants((p0) => true);
    database.currentParticipant = null;
    database.currentContractacions = [];

    await Navigator.push(
        context, SlideLeftRoute(widget: ParticipantsListWidget(true, id, true, true)));
    setState(() {});
  }

  void gotoServeisList() async {
    await Navigator.push(context, SlideLeftRoute(widget: const ServeiListWidget()));
    setState(() {});
  }

  void gotoCompres() async {
    await Navigator.push(context, SlideLeftRoute(widget: const CompresListWidget()));
    setState(() {});
  }

  void gotoSettings() async {
    await Navigator.push(context, SlideUpRoute(widget: SettingsView(title: widget.title,)));
    setState(() {});
  }

  void sendMails() async {

    await Navigator.push(
        context, SlideLeftRoute(widget: const SendEmailView()));
    setState(() {});

  }
  void showData(List<String> response) async {
    var status = response[0];
    var op = response[1];
    var data = response.sublist(2);

    setState(() {
      answerStatus = status;
      answerOp = op;
      returnedData = data;
    });
  }

  void showError() {
    Alerts.displayAlert(
        context, "Error de Connexió", database.lastServerError);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.


    List<Widget> icons = [];
    int c = min(database.backLogCount(), 10);
    if (c > 0) {
      icons.add(IconButton(
          icon: Icon(numberIcons[c - 1]),
          color: Colors.red,
          onPressed: () async {
            await showBacklog(context);
          setState(() {

          });
          }));
    }

    print("Backlog count ${database.backLogCount()}" );
    if (database.lastServerError.isNotEmpty) {
      icons.add(IconButton(
          icon: const Icon(Icons.warning_amber),
          color: Colors.red,
          onPressed: showError));
    }

    List<Widget> widgetList = [
      ElevatedButton(
          onPressed: gotoRegistre,
          onLongPress: () async {

            String? password = await Alerts.displayTextInputDialog(context, title: "Entreu el password", label : "Password", message : "Entreu el password de administració", password : true);

            if (password != null && password.isNotEmpty && password == "um23zap") {
              setState(() {
                admin = !admin;
              });
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white30,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: const BorderSide(color: Colors.black))),
          child: const Text("Registre",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    ];

    for (Servei servei in database.searchServeis((p0) {
      DateTime now = DateTime.now();
      Servei s = p0 as Servei;
      return (now.isAfter(s.valid.start) && now.isBefore(s.valid.end));
    })) {
      widgetList.add(const Text(" "));
      widgetList.add(
        ElevatedButton(
            onPressed: () {
              gotoServei(servei.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white30,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: Colors.black))),
            child: Text(servei.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      );
    }

    if (admin) {
      widgetList.add(const Text(" "));
      widgetList.add(const Divider(color: Colors.black));
      widgetList.add(const Text(" "));
      widgetList.add(ElevatedButton(
          onPressed: gotoParticipants,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white30,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: const BorderSide(color: Colors.black))),
          child: const Text("Participants",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))));

      widgetList.add(const Text(" "));
      widgetList.add(
        ElevatedButton(
            onPressed: () async {
                sendMails();
             },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white30,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: Colors.black))),
            child: const Text("Enviar missatges",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      );
      widgetList.add(const Text(" "));
      widgetList.add(
        ElevatedButton(
            onPressed: () {
              gotoCompres();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white30,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: Colors.black))),
            child: const Text("Compres",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      );
      widgetList.add(const Text(" "));
      widgetList.add(
        ElevatedButton(
            onPressed: () {
              gotoServeisList();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white30,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: Colors.black))),
            child: const Text("Serveis",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      );
      widgetList.add(const Text(" "));
      widgetList.add(
        ElevatedButton(
            onPressed: () { gotoSettings(); },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white30,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: Colors.black))),
            child: const Text("Ajustos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      );
    }
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title, textAlign: TextAlign.center,),
        //backgroundColor: database.lastServerError.isEmpty ? Colors.grey : Colors.red,
        actions: icons,
      ),
      body: SafeArea(
        minimum:
        const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
        child: Center(
          child: Container(
            alignment: Alignment.center,
            width: 300,
            child: ListView(
              controller: ScrollController(),
              children: widgetList,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:simposi23/CompresListWidget.dart';
import "SlideRoutes.dart";
import 'ParticipantsListWidget.dart';
import 'Database.dart';
import 'Server.dart';
import 'Participant.dart';
import 'Servei.dart';
import 'ServeiListWidget.dart';
import 'dart:math';
import 'LabeledSegments.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simposi Pagaia 2023',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(title: 'Simposi Pagaia 2023'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  Database database = Database.shared;
  String answerStatus = "";
  String answerOp = "";
  List<String> returnedData = [];

  String serverAddress = "";
  String appPath = "";
  Protocol protocol = Protocol.http;
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

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    database.removeSubscriptors(this);
    super.dispose();
  }

  void modelUpdated(String status, String message, String op) {
    final _isTopOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;



    if (status != "OK" && _isTopOfNavigationStack) {
      //Database.displayAlert(context, "ERROR in main", message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      setState(() {

      });
    }
    if (_isTopOfNavigationStack) {
      setState(() {});
    }
  }

  void gotoParticipants() async {
    database.selectedParticipants = database.searchParticipants((p0) => true);
    database.currentParticipant = null;
    database.currentContractacions = [];

    await Navigator.push(
        context, SlideLeftRoute(widget: ParticipantsListWidget(true, 0)));
    setState(() {});
  }

  void gotoRegistre() async {
    database.selectedParticipants = database.searchParticipants((p0) {
      Participant p1 = p0 as Participant;
      return !p1.registrat;
    });
    database.currentParticipant = null;
    database.currentContractacions = [];

    await Navigator.push(
        context, SlideLeftRoute(widget: ParticipantsListWidget(false, 0)));
    setState(() {});
  }

  void gotoServei(int id) async {
    database.selectedParticipants = database.searchParticipants((p0) => true);
    database.currentParticipant = null;
    database.currentContractacions = [];

    await Navigator.push(
        context, SlideLeftRoute(widget: ParticipantsListWidget(true, id)));
    setState(() {});
  }

  void gotoServeisList() async {
    await Navigator.push(context, SlideLeftRoute(widget: ServeiListWidget()));
    setState(() {});
  }

  void gotoCompres() async {
    await Navigator.push(context, SlideLeftRoute(widget: CompresListWidget()));
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
    Database.displayAlert(
        context, "Error de Connexió", database.lastServerError);
  }

  void askForServer() {
    Database.displayTextInputDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    if (database.server.host.isNotEmpty) {
      return buildNormal(context);
    } else {
      return buildNeedServer(context);
    }
  }

  Widget buildNeedServer(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    List<Widget> icons = [];
    int c = min(database.backLogCount(), 10);
    if (c > 0) {
      icons.add(IconButton(
          icon: Icon(numberIcons[c - 1]),
          color: Colors.red,
          onPressed: () async {
            await showBacklog(context);
            setState(() {});
          }));
    }

    if (database.lastServerError.isNotEmpty) {
      icons.add(IconButton(
          icon: const Icon(Icons.warning_amber),
          color: Colors.red,
          onPressed: showError));
    }


    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: icons,
        //backgroundColor: database.lastServerError.isEmpty ? Colors.grey : Colors.red,
      ),
      body: SafeArea(
        minimum:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            Text(
              "Configuració Inicial",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text("S'han d'introduir les dades del servidor"),
            Divider(),
            labeledSegmentsFromText("Protocol", ["http", "https"],
                protocol == Protocol.http ? 0 : 1, (i) {
              setState(() {
                switch (i) {
                  case 0:
                    protocol = Protocol.http;
                    break;

                  default:
                    protocol = Protocol.https;
                }
                ;
              });
            }),
            TextFormField(
              initialValue: serverAddress,
              autocorrect: false,
              enableSuggestions: false,

              decoration: const InputDecoration(
                icon: Icon(Icons.computer),
                hintText: 'Enter IP:port of the server',
                labelText: 'Server',
              ),
              onChanged: (String? value) {
                serverAddress = value ?? "";
              },
              validator: (String? value) {
                //return (value != null && value.contains('@')) ? 'Do not use the @ char.' : null;
                return null;
              },
            ),
            TextFormField(
              initialValue: appPath,
              autocorrect: false,
              enableSuggestions: false,
             decoration: const InputDecoration(
                icon: Icon(CupertinoIcons.gear),
                hintText: 'Enter the path to the app',
                labelText: 'Path',
              ),
               onChanged: (String? value) {
                appPath = value ?? "";
              },
              validator: (String? value) {
                //return (value != null && value.contains('@')) ? 'Do not use the @ char.' : null;
                return null;
              },
            ),
            TextFormField(
              initialValue: terminal.toString(),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                icon: Icon(CupertinoIcons.device_phone_portrait),
                hintText: 'Entreu el número de terminal',
                labelText: 'Terminal',
              ),
              onChanged: (String? value) {
                terminal = int.tryParse(value ?? "1") ?? 1;
              },
              validator: (String? value) {
                //return (value != null && int.tryParse(value) != null) ? null : "Terminal ha de ser numèric.";
                return null;
              },
            ),
            Text(" "),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.white30,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black))),
              onPressed: () async{
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  try {
                    print("$protocol://$serverAddress/$appPath $terminal");
                    database.terminal = terminal;
                    await database.setServerAddress(protocol, serverAddress, appPath);

                    if(database.lastServerError.isNotEmpty){
                      database.server.host = "";
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error " + database.lastServerError)),
                      );
                    }else {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    }

                  } catch (e, backtrace) {
                    print(e.toString() + "\n" + backtrace.toString());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error " + e.toString())),
                    );
                    database.server.host = "";
                    setState(() {

                    });
                    }
                }
              },
              child: const Text('Guardar'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget buildNormal(BuildContext context) {
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
            setState(() {});
          }));
    }

    if (database.lastServerError.isNotEmpty) {
      icons.add(IconButton(
          icon: const Icon(Icons.warning_amber),
          color: Colors.red,
          onPressed: showError));
    }

    List<Widget> widgetList = [

      ElevatedButton(
          onPressed: gotoRegistre,
          onLongPress: () {
            setState(() {
              admin = !admin;
            });
          },
          child: Text("Registre",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(

              primary: Colors.white30,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black)))),
    ];

    for (Servei servei in database.searchServeis((p0) {
      DateTime now = DateTime.now();
      Servei s = p0 as Servei;
      return (now.isAfter(s.valid.start) && now.isBefore(s.valid.end));
    })) {
      widgetList.add(Text(" "));
      widgetList.add(
        ElevatedButton(
            onPressed: () {
              gotoServei(servei.id);
            },
            child: Text(servei.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                primary: Colors.white30,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.black)))),
      );
    }
    ;

    if (admin) {
      widgetList.add(Text(" "));
      widgetList.add(Divider(color: Colors.black));
      widgetList.add(Text(" "));
      widgetList.add(ElevatedButton(
          onPressed: gotoParticipants,
          child: Text("Participants",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              primary: Colors.white30,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black)))));

      widgetList.add(Text(" "));

      widgetList.add(
        ElevatedButton(
            onPressed: () {
              gotoCompres();
            },
            child: Text("Compres",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                primary: Colors.white30,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.black)))),
      );
      widgetList.add(Text(" "));
      widgetList.add(
        ElevatedButton(
            onPressed: () {
              gotoServeisList();
            },
            child: Text("Serveis",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                primary: Colors.white30,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.black)))),
      );
      widgetList.add(Text(" "));
      widgetList.add(
        ElevatedButton(
            onPressed: () {
              setState(() {
                serverAddress = database.server.host;
                appPath = database.server.url;
                protocol = database.server.protocol;
                terminal = database.terminal;
                database.server.host = "";
              });
            },
            child: Text("Reset Server",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                primary: Colors.white30,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.black)))),
      );
    }
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        //backgroundColor: database.lastServerError.isEmpty ? Colors.grey : Colors.red,
        actions: icons,
      ),
      body: SafeArea(
        minimum:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
        child: Center(
      child: Container(
          alignment: Alignment.center,
          width: 300,
          child:ListView(
          controller: ScrollController(),
          children: widgetList,
        ),
      ),
        ),
      ),
    );
  }
}

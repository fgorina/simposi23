import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simposi23/CompresListWidget.dart';
import "SlideRoutes.dart";
import 'ParticipantsListWidget.dart';
import 'Database.dart';
import 'Server.dart';
import 'Participant.dart';
import 'Servei.dart';
import 'ServeiListWidget.dart';
import 'dart:math';



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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{

  Database database = Database.shared;
  String answerStatus = "";
  String answerOp = "";
  List<String> returnedData = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("State $state");

      if (state == AppLifecycleState.resumed) {
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
      Database.displayAlert(context, "ERROR in main", message);
    }
    if(_isTopOfNavigationStack) {
      setState(() {

      });
    }
  }

  void gotoParticipants() async{
    database.selectedParticipants = database.searchParticipants((p0)  => true);
    database.currentParticipant = null;
    database.currentContractacions = [];

    await Navigator.push(context, SlideLeftRoute(widget: ParticipantsListWidget(true, 0)));
    setState(() {

    });
  }
  void gotoRegistre() async{
    database.selectedParticipants = database.searchParticipants((p0)  {
      Participant p1 = p0 as Participant;
      return !p1.registrat;
    });
    database.currentParticipant = null;
    database.currentContractacions = [];

    await Navigator.push(context, SlideLeftRoute(widget: ParticipantsListWidget(false, 0)));
    setState(() {

    });
    }

  void gotoServei(int id) async{
    database.selectedParticipants = database.searchParticipants((p0)  => true);
    database.currentParticipant = null;
    database.currentContractacions = [];

    await Navigator.push(context, SlideLeftRoute(widget: ParticipantsListWidget(true, id)));
    setState(() {

    });
  }

  void gotoServeisList() async{
    await Navigator.push(context, SlideLeftRoute(widget: ServeiListWidget()));
    setState(() {

    });
  }

  void gotoCompres() async{
    await Navigator.push(context, SlideLeftRoute(widget: CompresListWidget()));
    setState(() {

    });
  }


  void testServerOk() async{
    var s = Server("192.168.1.196:8888", "simposi23.php");
    try{
      await s.getData("participants", "", showData);
    }catch(e){
      setState(() {
        answerStatus = "Exception";
        answerOp = "";
        returnedData = [e.toString()];
      });
    }
  }

  void testServerError() async{
    var s = Server("192.168.1.196:8888", "simposi23.php");
    try{
      await s.getData("participantes", "12345", showData);
    }catch(e){
      setState(() {
        answerStatus = "Exception";
        answerOp = "";
        returnedData = [e.toString()];
        returnedData = [e.toString()];
      });
    }
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


  void showError(){
    Database.displayAlert(context, "Error de Connexió", database.lastServerError);
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
    if (c > 0 ){
      icons.add(IconButton(icon: Icon(numberIcons[c-1]), color: Colors.red, onPressed: () async {
        await showBacklog(context);
        setState(() {

        });

      }));
    }

    if(database.lastServerError.isNotEmpty){
      icons.add(IconButton(icon: const Icon(Icons.warning_amber), color: Colors.red, onPressed: showError));
    }

    List<Widget> widgetList = [
      ElevatedButton(onPressed: gotoRegistre,
          child: Text("Registre",style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              primary: Colors.white30,
              shape:
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black)
              )
          )
      ),
    ];

    for (Servei servei in database.searchServeis((p0) {
        DateTime now = DateTime.now();
        Servei s = p0 as Servei;
        return (now.isAfter(s.valid.start) && now.isBefore(s.valid.end));
      })){
       widgetList.add(Text(" "));
        widgetList.add(
          ElevatedButton(onPressed: (){
            gotoServei(servei.id);
          },
              child: Text(servei.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  primary: Colors.white30,
                  shape:
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black)))
          ),
        );
    };

    widgetList.add(Divider(color: Colors.black));

    widgetList.add(ElevatedButton(onPressed: gotoParticipants,
        child: Text("Participants", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
  primary: Colors.white30,
            shape:
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.black)))
    )
    );



    widgetList.add(
      ElevatedButton(onPressed: (){
        gotoCompres();
      },
          child: Text("Compres", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              primary: Colors.white30,
              shape:
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black)))),
    );

    widgetList.add(
      ElevatedButton(onPressed: (){
        gotoServeisList();
      },
          child: Text("Serveis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              primary: Colors.white30,
              shape:
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black)))
      ),
    );
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        //backgroundColor: database.lastServerError.isEmpty ? Colors.grey : Colors.red,
        actions: icons,

      ),
      body: SafeArea(
        minimum: EdgeInsets.only(
            left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
        child: ListView(
          controller: ScrollController(),
          children:widgetList,
        ),
      ),
    );
  }
}

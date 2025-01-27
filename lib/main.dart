import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import "SlideRoutes.dart";
import 'Database.dart';
import 'Server.dart';
import 'SettingsView.dart';
import 'MainView.dart';
import 'Alerts.dart';

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
  void initState() {

    super.initState();
    database.addSubscriptor(this);
  }

  @override
  void dispose() {
    database.removeSubscriptors(this);
    super.dispose();
  }

  void modelUpdated(String status, String message, String op) async {
    final isTopOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;

    if (status != "OK" && isTopOfNavigationStack) {
      //Database.displayAlert(context, "ERROR in main", message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      setState(() {});
    }

    else if (status == "OK" && isTopOfNavigationStack && database.initialized){
      gotoMainWiew();
    }
    }

  Future gotoMainWiew() async {

     if(database.server.host.isEmpty){
       Navigator.pushReplacement(context, NoTransitionRoute(widget: MainView(title: widget.title)));
       await Navigator.push(
           context, SlideUpRoute(widget: SettingsView(title: widget.title)));
     } else {
       await Navigator.pushReplacement(
           context, SlideUpRoute(widget: MainView(title: widget.title)));
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

  void showError() {
    Alerts.displayAlert(
        context, "Error de Connexió", database.lastServerError);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, textAlign: TextAlign.center,),
      ),
      body: const SafeArea(
        minimum:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            SizedBox(
              width: 224,
              height: 224,
              child: CupertinoActivityIndicator(animating: true, radius: 30),
            ),
            Spacer(),
            Text("Carregant Configuració", textAlign: TextAlign.center, style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),),
            Spacer(),
          ],
        ),
    ),
      ),
    );
  }
}

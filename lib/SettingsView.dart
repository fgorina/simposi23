import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'Database.dart';
import 'Server.dart';
import 'dart:math';
import 'LabeledSegments.dart';
import 'Alerts.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with WidgetsBindingObserver {
  Database database = Database.shared;

  String serverAddress = "";
  String appPath = "";
  Protocol protocol = Protocol.http;
  int terminal = 1;


  void initState(){
  super.initState();
  serverAddress = database.server.host;
  appPath = database.server.url;
  protocol = database.server.protocol;
  terminal = database.terminal;

}
  void showError() {
    Alerts.displayAlert(
        context, "Error de Connexió", database.lastServerError);
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    String error = "";

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
        title: Text(widget.title, textAlign: TextAlign.center,),
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
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  try {
                    print("$protocol://$serverAddress/$appPath $terminal");
                    database.terminal = terminal;
                    await database.setServerAddress(
                        protocol, serverAddress, appPath);

                    if (database.lastServerError.isNotEmpty) {

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Error " + database.lastServerError)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      Navigator.pop(context);
                    }
                  } on ClientException catch (e){
                    error = e.toString() + "\n" + e.message + "\n";
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error http" + e.toString())),

                    );

                    setState(() {});
                  }

                  catch (e, backtrace) {
                      error = e.toString();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error " + e.toString())),

                    );
                    database.server.host = "";
                    setState(() {});
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
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'Servei.dart';
import 'Database.dart';
import 'dart:math';
import 'screensize_reducers.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'Alerts.dart';


class ServeiView extends StatefulWidget {
  final String title = "Servei";
  Servei servei;

  ServeiView(this.servei, {super.key});
  @override
  _ServeiViewState createState() => _ServeiViewState();
}

class _ServeiViewState extends State<ServeiView> {
  Database d = Database.shared;

  DateFormat df = DateFormat("dd/MM");

  String name = "";
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  String field = "";
  int idProducte = 1;

  @override
  void initState() {
    super.initState();
    d.addSubscriptor(this);

    name = widget.servei.name;
    start = widget.servei.valid.start;
    end = widget.servei.valid.end;
    field = widget.servei.field;
    idProducte = widget.servei.idProducte;
  }

  @override
  void dispose() {
    d.removeSubscriptors(this);
    super.dispose();
  }

  void modelUpdated(String status, String message, String op) {
    final isTopOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;

    if (status != "OK" && isTopOfNavigationStack) {
      //Database.displayAlert(context, "STOP", message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    if (op == "serveis") {
      setState(() {});
    }
  }

  void showError() {
    Alerts.displayAlert(context, "Error de Connexió", d.lastServerError);
  }


  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    var formatter = DateFormat("d/M/y H:m:s");

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

    if (d.lastServerError.isNotEmpty) {
      icons.add(IconButton(
          icon: const Icon(Icons.warning_amber, color: Colors.red),
          onPressed: showError));
    }



    List<DropdownMenuItem<int>> productes = d
        .allProductes()
        .map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.name)))
        .toList();

    ScrollController controller = ScrollController();

    return KeyboardSizeProvider(
      smallSize: 500.0,
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.servei.name),

          actions: icons,
        ),
        body: Consumer<ScreenHeight>(builder: (context, res, child) {
          return SafeArea(
            minimum: const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: widget.servei.name,
                    autocorrect: true,
                    enableSuggestions: true,
                    decoration: const InputDecoration(
                      icon: Icon(CupertinoIcons.chat_bubble_text),
                      hintText: 'Entreu el nom del servei',
                      labelText: 'Servei',
                    ),
                    onSaved: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        name = value;
                      }
                    },
                    validator: (String? value) {
                      return (value != null && value.isNotEmpty)
                          ? null
                          : "El nom del servei ha de estar informat!";
                    },
                  ),
                  TextFormField(
                    initialValue: formatter.format(start),
                    autocorrect: true,
                    enableSuggestions: true,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.start),
                      hintText:
                          'Entreu la data de inici de la validesa del servei',
                      labelText: 'Data inici',
                    ),
                    onSaved: (String? value) {
                      try {
                        start = formatter.parseLoose(value ?? "");
                      } on FormatException catch (e) {
                        print("Error de Format ${e.toString()}");
                      }
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "El nom del servei ha de estar informat!";
                      }
                      try {
                        DateTime aDateTime = formatter.parseLoose(value);
                      } on FormatException catch (e) {
                        return e.message;
                      }

                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: formatter.format(end),
                    autocorrect: true,
                    enableSuggestions: true,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.keyboard_tab),
                      hintText:
                          'Entreu la data de fi de la validesa del servei',
                      labelText: 'Data final',
                    ),
                    onSaved: (String? value) {
                      try {
                        end = formatter.parseLoose(value ?? "");
                      } on FormatException catch (e) {
                        print("Error de Format ${e.toString()}");
                      }
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "El nom del servei ha de estar informat!";
                      }
                      try {
                        DateTime aDateTime = formatter.parseLoose(value);
                      } on FormatException catch (e) {
                        return e.message;
                      }

                      return null;
                    },
                  ),
              TextFormField(
                initialValue: widget.servei.field,
                autocorrect: true,
                enableSuggestions: true,
                decoration: const InputDecoration(
                  icon: Icon(CupertinoIcons.chat_bubble_text),
                  hintText: 'Entreu el camp a wpdj_pagaia_qr_sympo2023',
                  labelText: 'Camp',
                ),
                onSaved: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    field = value;
                  }
                },
                validator: (String? value) {
                  return (value != null && value.isNotEmpty)
                      ? null
                      : "El nom del camp ha de estar informat!";
                },
              ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(children: [
                    const Icon(
                      Icons.shopping_cart,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 15),
                    SizedBox(
                      width: screenWidth(context) - 80,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Producte",
                              textAlign: TextAlign.left,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            DropdownButtonFormField<int>(
                              hint: const Text("Seleccioneu el producte"),
                              items: productes,
                              value: idProducte,
                              onChanged: (v) {
                                print("Selected : $v");
                              },
                              onSaved: (v) {
                                idProducte = (v ?? 0);
                              },
                            ),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white30,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: const BorderSide(color: Colors.black))),
                        child: const Text('Guardar'),
                        onPressed: () async {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (formKey.currentState!.validate()) {
                            print("Validació Correcte");
                            formKey.currentState!.save();

                            widget.servei.name = name;
                            widget.servei.valid =
                                DateTimeRange(start: start, end: end);
                            widget.servei.field = field;
                            widget.servei.idProducte = idProducte;
                            d.saveData();
                            // Post Servei!!!
                            await d.updateServei(widget.servei);
                            Navigator.pop(context);

                          } else {
                            print("Error al validar el servei");
                          }
                        }),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

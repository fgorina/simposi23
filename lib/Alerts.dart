import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'legacy_buttons.dart';

class Alerts {
// Alerts

  static Future<String?> displayTextInputDialog(BuildContext context,
      {title = "", label: "", message = "", password = false, initialValue = ""}) async {
    String? theValue = initialValue;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Container(
            width: 300,
            height: 300,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: message,
                      labelText: label,
                    ),
                    obscureText: password,
                    enableSuggestions: !password,
                    autocorrect: !password,
                    onChanged: (value) {
                      theValue = value;
                    },

                  ),
                  Spacer(),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      CupertinoButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.pop(context, theValue);
                          }),
                      Spacer(),
                      CupertinoButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context, null);
                          }),
                      Spacer(),
                    ],
                  ),
                ]),
            ),
          );
        });
  }

  static Future<bool?> yesNoAlert(
      BuildContext context, String title, String message) async {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(
              message,
            ),
            actions: <Widget>[
              new LegacyFlatButton(
                child: new Text("Si",
                    style: TextStyle(
                      fontSize: 18,
                    )),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              new LegacyFlatButton(
                child: new Text("No",
                    style: TextStyle(
                      fontSize: 18,
                    )),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
  }

  static displayAlert(
      BuildContext context, String title, String message) async {
    return showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(
              message,
            ),
            actions: <Widget>[
              new LegacyFlatButton(
                child: new Text("OK",
                    style: TextStyle(
                      fontSize: 18,
                    )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}

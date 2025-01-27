import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'legacy_buttons.dart';

class Alerts {
// Alerts

  static Future<String?> displayTextInputDialog(BuildContext context,
      {title = "", label= "", message = "", password = false, initialValue = ""}) async {
    String? theValue = initialValue;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
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
                  const Spacer(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      CupertinoButton(
                          child: const Text("OK"),
                          onPressed: () {
                            Navigator.pop(context, theValue);
                          }),
                      const Spacer(),
                      CupertinoButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context, null);
                          }),
                      const Spacer(),
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
              LegacyFlatButton(
                child: const Text("Si",
                    style: TextStyle(
                      fontSize: 18,
                    )),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              LegacyFlatButton(
                child: const Text("No",
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
              LegacyFlatButton(
                child: const Text("OK",
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

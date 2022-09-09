import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Widget labeledSwitch(String name, bool value,  void Function(bool)? changed, {bool enabled = true}){


  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    mainAxisSize: MainAxisSize.max,
    children: [
      Text(name,),
      CupertinoSwitch(value: value, onChanged: enabled ? changed : null,),
    ]
  );
}


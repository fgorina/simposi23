import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


Widget labeledSegments(
    String name, Map<int, Widget> segments, int selected, Function(int) changed,
    {bool enabled = true}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(name, ),
      CupertinoSegmentedControl( children: segments,
          borderColor: Colors.blue,
          pressedColor: Colors.lightBlue,
          selectedColor: Colors.blue,
          unselectedColor: Colors.white,
          onValueChanged: changed, groupValue: selected),
     ],
  );
}

Widget labeledSegmentsFromTextNoTitle(
    List<String> segments, int selected, Function(int) changed,
    {bool enabled = true}) {
  Map<int, Widget> children = {};

  for (int i = 0; i < segments.length; i++) {
    children[i] = Padding(
        padding: EdgeInsets.only(left: 5, top: 0.0, right: 5.0, bottom: 0.0),
        child: Text(segments[i]));
  }
  return CupertinoSegmentedControl( children: children, onValueChanged: changed, groupValue: selected);

}

Widget labeledSegmentsFromText(
    String name, List<String> segments, int selected, Function(int) changed,
    {bool enabled = true}) {
  Map<int, Widget> children = {};

  for (int i = 0; i < segments.length; i++) {
    children[i] = Padding(
        padding: EdgeInsets.only(left: 5, top: 0.0, right: 5.0, bottom: 0.0),
        child: Text(segments[i]));
  }
  return labeledSegments(name, children, selected, changed, enabled: enabled);
}


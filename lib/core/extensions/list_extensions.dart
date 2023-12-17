import 'package:flutter/material.dart';

extension IterableEx<T> on Iterable<T> {
  Iterable<Widget> inBetween(Widget seperator) {
    final items = <Widget>[];
    for (var i = 0; i < length; i++) {
      items.add(toList()[i] as Widget);
      items.add(seperator);
    }
    return items;
  }
}

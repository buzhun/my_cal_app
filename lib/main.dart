import 'package:flutter/material.dart';
import './opt.dart';

void main() {
  bool isLargeScreen = false;
  runApp(
    MaterialApp(
        title: 'calculator',
        home: Scaffold(
          body: OrientationBuilder(builder: (context, orientation) {
            if (MediaQuery.of(context).size.width > 600) {
              isLargeScreen = true;
            } else {
              isLargeScreen = false;
            }
            return OptWidget(isLargeScreen: isLargeScreen);
          }),
        )),
  );
}

// OptWidget manages the state.

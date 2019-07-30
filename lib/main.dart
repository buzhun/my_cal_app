import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import './opt.dart';

void main() {
  runApp(
    MaterialApp(title: '毛球计算器', home: new ThemeHome()),
  );
}

class ThemeHome extends StatefulWidget {
  ThemeHome({
    Key key,
  }) : super(key: key);

  @override
  _ThemeHomeState createState() => _ThemeHomeState();
}

class _ThemeHomeState extends State<ThemeHome> {
  static const platform = const MethodChannel('samples.flutter.dev/theme');

  bool _themeIsBlack = true;

  @override
  void initState() {
    super.initState();
    // 初始化主题状态
    _getTheme();
  }

  Future<void> _getTheme() async {
    try {
      final String result = await platform.invokeMethod('_getTheme');
      setState(() {
        _themeIsBlack = result == 'black';
      });
    } on PlatformException catch (e) {
      print('error:$e');
    }
  }

  Future<void> _setTheme(value) async {
    String color = value ? "black" : 'white';
    try {
      final String result = await platform.invokeMethod('_setTheme', color);
      setState(() {
        _themeIsBlack = result == 'black';
      });
    } on PlatformException catch (e) {
      print('can not change theme :${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    {
      return Scaffold(
        body: MyHomePage(themeIsBlack: _themeIsBlack),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Text('毛球计算器'),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
              ),
              CheckboxListTile(
                title: const Text('黑色主题'),
                value: _themeIsBlack,
                onChanged: (bool value) {
                  _setTheme(value);
                },
                secondary: const Icon(Icons.brightness_3),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    this.themeIsBlack,
    Key key,
  }) : super(key: key);

  final bool themeIsBlack;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static bool _isLargeScreen = false;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        _isLargeScreen = true;
      } else {
        _isLargeScreen = false;
      }
      return OptWidget(
          isLargeScreen: _isLargeScreen, themeIsBlack: widget.themeIsBlack);
    });
  }
}

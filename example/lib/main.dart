import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutterpd/flutterpd.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Flutterpd().platformVersion;
      Flutterpd().open("assets/generator.pd");
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
            children: [
              Center(child: Text('Running on: $_platformVersion\n')),
              RaisedButton(child: Text("Init Audio"),
                  onPressed: () { Flutterpd().initAudio(44100, 0, 2); }),
              RaisedButton(child: Text("Start Audio"),
              onPressed: () { Flutterpd().startAudio(); }),
              RaisedButton(child: Text("Stop Audio"),
                  onPressed: () { Flutterpd().stopAudio(); }),
              RaisedButton(child: Text("Turn on"),
                  onPressed: () { Flutterpd().sendFloat("toggle", 1.0); }),
              RaisedButton(child: Text("Turn off"),
                  onPressed: () { Flutterpd().sendFloat("toggle", 0.0); }),
              RaisedButton(child: Text("Set 440Hz"),
                  onPressed: () { Flutterpd().sendFloat("freq", 440.0); }),
            ]),
      ),
    );
  }
}

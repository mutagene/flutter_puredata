import 'dart:async';

import 'package:flutter/services.dart';

class Flutterpd {
  static const MethodChannel _channel =
      const MethodChannel('org.puredata/flutterpd');

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  void open(String file) {
    _channel.invokeMethod("open", <String, dynamic>{
      "file": file
    });
  }

  void initAudio(int sampleRate, int inChannels, int outChannels) {
    _channel.invokeMethod("initAudio", <String, dynamic>{
      "sampleRate": sampleRate,
      "inChannels": inChannels,
      "outChannels": outChannels
    });
  }

  void startAudio() {
    _channel.invokeMethod("startAudio");
  }

  void stopAudio() {
    _channel.invokeMethod("startAudio");
  }

  void sendBang(String receiver) {
    _channel.invokeMethod("sendBang", <String, dynamic>{
      "receiver": receiver
    });
  }

  void sendFloat(String receiver, double value) {
    _channel.invokeMethod("sendFloat", <String, dynamic>{
      "receiver": receiver,
      "value": value
    });
  }

  Future<bool> isRunning() async {
    return await _channel.invokeMethod("isRunning");
  }

  void dispose() {
    _channel.invokeMethod("dispose");
  }
}

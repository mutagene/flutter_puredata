# flutterpd

Puredata plugin for mobile. Bare-bones required to start and stop audio. 

# API, such as it is

## Open

`void open(String file)`

Opens a PD preset after preparing the file as required.
* Android libpd: `PdBase.openPatch(...)`
* iOS libpd-ios: `PdBase.openFile(...)`
```
    Flutterpd().open("assets/generator.pd");
```

## initAudio

`void initAudio(int sampleRate, int inChannels, int outChannels)`

Initializes the audio 
* Android libpd: `PdAudio.initAudio(...)`
* iOS libpd-ios: `pdAudioController.configureAmbient(...)`
```
    Flutterpd().initAudio(44100, 0, 2);
```

## startAudio

`void startAudio()`

Starts audio processing
* Android libpd: `PdAudio.startAudio()` 
* iOS libpd-ios: `pdAudioController.isActive = true`
```
    Flutterpd().startAudio();
```

## stopAudio

`void stopAudio()`

Stops audio processing
* Android libpd: `PdAudio.stopAudio()` 
* iOS libpd-ios: `pdAudioController.isActive = false`
```
    Flutterpd().stopAudio();
```

## sendBang & sendFloat

`void sendBang(String receiver)` / `sendFloat(String receiver, double value)`

Sends a bang or a float to the specified receiver
* Android/iOS libpd: `PdBase.sendBang/sendFloat(...)`
```
    Flutterpd().sendBang("trigger");
    Flutterpd().sendFloat("freq", 440.0);
```

## isRunning

`Future<bool> isRunning() async`

Checks if audio is processing
* Android libpd: `PdAudio.isRunning()`
* iOS libpd-ios: `pdAudioController.isActive`
```
    var running = await Flutterpd().isRunning();
```

# Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

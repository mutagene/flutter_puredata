import Flutter
import UIKit
import libpd

public class SwiftFlutterpdPlugin: NSObject, FlutterPlugin {
  let pdAudioController = PdAudioController()
  var registrar : FlutterPluginRegistrar?

  static let CHANNEL_NAME = "org.puredata/flutterpd"
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterpdPlugin()
    instance.registrar = registrar
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch(call.method) {
    case "open":
        let args = call.arguments as! NSDictionary
        guard let file = (args["file"] as? String) else {
            print("\(SwiftFlutterpdPlugin.CHANNEL_NAME) -> open(\(args)) - illegal and ignored")
            return
        }
        open(file: file)
        break;
    case "initAudio":
        let args = call.arguments as! NSDictionary
        let sampleRate = (args["sampleRate"] as? NSNumber ?? 44100).int32Value
        let inChannel = (args["inChannel"] as? NSNumber ?? 0).int32Value
        let outChannels = (args["outChannels"] as? NSNumber ?? 2).int32Value
        let pdInit = pdAudioController?.configureAmbient(withSampleRate: sampleRate, numberChannels: outChannels, mixingEnabled: true)
        if pdInit != PdAudioOK {
          print( "Error, could not instantiate pd audio engine" )
        }
        result(nil)
        break;
    case "sendFloat":
        let args = call.arguments as! NSDictionary
        let receiver = args["receiver"] as! String
        guard let number = (args["value"] as? NSNumber) else {
            print("\(SwiftFlutterpdPlugin.CHANNEL_NAME) -> sendFloat(\(receiver), null) - illegal and ignored")
            return
        }
        let value = number.floatValue
        PdBase.send(value, toReceiver: receiver)
        result(nil)
        break;
    case "sendBang":
        let args = call.arguments as! NSDictionary
        let receiver = args["receiver"] as! String
        PdBase.sendBang(toReceiver: receiver)
        print("\(SwiftFlutterpdPlugin.CHANNEL_NAME)  -> sendBang(\(receiver)")
        break;
    case "startAudio":
        pdAudioController?.isActive = true
        break;
    case "stopAudio":
        pdAudioController?.isActive = false
        break;
    case "isRunning":
        result(pdAudioController?.isActive)
        break;
    case "dispose":
        print("Not disposing Pd resources on iOS")
        break;
    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
        break;
    default:
        print("Not handled method \(call.method)")
        break;
    }
  }

    func open(file assetPath: String) {
        guard let keyProvider = registrar else {
            print( "initialize must be set with valid registrar first")
            return
        }
        let nullableFileKey = keyProvider.lookupKey(forAsset: assetPath) as String?
        guard let pdFileKey = nullableFileKey else {
            print( "Unable to locate asset at ", assetPath)
            return
        }
        let pdFilePath = Bundle.main.path(forResource: pdFileKey, ofType: nil)
        let pdBaseName = (pdFilePath! as NSString).lastPathComponent
        let pdDirectory = (pdFilePath! as NSString).deletingLastPathComponent
        let pdFile = PdBase.openFile(pdBaseName, path: pdDirectory)
        if pdFile == nil {
            print( "Failed to open pure data file ", assetPath)
        }
    }
    
}


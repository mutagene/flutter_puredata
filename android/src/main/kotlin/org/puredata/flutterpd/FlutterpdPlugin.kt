package org.puredata.flutterpd

import android.app.Activity
import android.content.Context
import android.content.res.AssetFileDescriptor
import android.content.res.AssetManager
import android.util.Log
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.puredata.android.io.PdAudio
import org.puredata.android.service.PdService
import org.puredata.android.utils.PdUiDispatcher
import org.puredata.core.PdBase
import java.io.File
import java.io.FileInputStream
import java.io.FileNotFoundException
import java.io.InputStream

/** FlutterpdPlugin */
public class FlutterpdPlugin(): FlutterPlugin, MethodCallHandler {
  var flutterAssets: FlutterPlugin.FlutterAssets? = null
  var context: Context? = null
  val pdService = PdService()
  var pdUiDispatcher = PdUiDispatcher();

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), CHANNEL_NAME)
    val plugin = FlutterpdPlugin()
    plugin.flutterAssets = flutterPluginBinding.flutterAssets
    plugin.context = flutterPluginBinding.applicationContext
    channel.setMethodCallHandler(plugin);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    const val CHANNEL_NAME = "org.puredata/flutterpd"
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
      val plugin = FlutterpdPlugin()
      plugin.flutterAssets = FlutterAssetAdapter(registrar)
      plugin.context = registrar.activeContext().applicationContext
      channel.setMethodCallHandler(plugin)
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "open" -> {
        val patchFile = call.argument<String>("file") ?: throw RuntimeException("Must provide path for pd file")
        openFile(patchFile)
        result.success(null)
      }
      "initAudio" -> {
        val sampleRate = call.argument<Int>("sampleRate") ?: 44100
        val inChannels = call.argument<Int>("inChannels") ?: 0
        val outChannels = call.argument<Int>("outChannels") ?: 2
        val ticksPerBuffer = call.argument<Int>("ticksPerBuffer") ?: 1
        PdAudio.initAudio(sampleRate, inChannels, outChannels, ticksPerBuffer, true)
      }
      "startAudio" -> {
        PdAudio.startAudio(context!!)
      }
      "stopAudio" -> {
        PdAudio.stopAudio()
      }
      "sendBang" -> {
        val receiver = call.argument<String>("receiver")
        PdBase.sendBang(receiver)
        result.success(null)
      }
      "sendFloat" -> {
        val receiver = call.argument<String>("receiver")
        val value = call.argument<Double>("value")
        PdBase.sendFloat(receiver, value!!.toFloat())
        result.success(null)
      }
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE} for libPD, audio: ${PdBase.audioImplementation()}, isRunning: ${PdAudio.isRunning()}")
      }
      "isRunning" -> {
        result.success(PdAudio.isRunning())
      }
      "dispose" -> {
        PdAudio.release()
        PdBase.release()
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }

  private fun openFile(patchFile: String) {
    if(File(patchFile).exists()) {
      PdBase.openPatch(patchFile)
    } else {
      val nullableKey = flutterAssets?.getAssetFilePathByName(patchFile);
      nullableKey?.let { key ->
        Log.w("FlutterPd", "key is $key");
        val tempFile = File.createTempFile("pd-patch-file", ".pd");
        val assetManager = context?.assets
        var inputStream: InputStream? = null
        try {
          val nullableFd = assetManager?.openFd(key)
          inputStream = nullableFd?.createInputStream()
        }
        catch(e: FileNotFoundException) {
          Log.e("FlutterPd", e.localizedMessage!!);
          inputStream = FileInputStream("assets/$key")
          Log.e("FlutterPd", "Making stream from key");
        }
        tempFile.copyInputStreamToFile(inputStream!!)
        Log.e("FlutterPd", "have temp file at ${tempFile.absolutePath} of size: ${tempFile.length()}")
        PdBase.openPatch(tempFile.absolutePath)
      }
    }
  }
}

class FlutterAssetAdapter(private val registrar: Registrar) : FlutterPlugin.FlutterAssets {
  override fun getAssetFilePathBySubpath(p0: String): String {
    return registrar.lookupKeyForAsset(p0);
  }

  override fun getAssetFilePathBySubpath(p0: String, p1: String): String {
    return registrar.lookupKeyForAsset(p0, registrar.activeContext().packageName);
  }

  override fun getAssetFilePathByName(p0: String): String {
    return registrar.lookupKeyForAsset(p0);
  }

  override fun getAssetFilePathByName(p0: String, p1: String): String {
    return registrar.lookupKeyForAsset(p0, registrar.activeContext().packageName);
  }
}

fun File.copyInputStreamToFile(inputStream: InputStream) {
  this.outputStream().use { fileOut ->
    inputStream.copyTo(fileOut)
  }
}
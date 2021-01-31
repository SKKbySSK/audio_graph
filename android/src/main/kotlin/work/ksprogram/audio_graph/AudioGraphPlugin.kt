package work.ksprogram.audio_graph

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.ArrayList

/** AudioGraphPlugin */
class AudioGraphPlugin: FlutterPlugin, MethodCallHandler {
  companion object {
    var context: Context? = null
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    AudioGraphPlugin.context = flutterPluginBinding.applicationContext

    val fileChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "audio_graph/file")
    AudioFilePlugin.methodChannel = fileChannel
    fileChannel.setMethodCallHandler(AudioFilePlugin())

    val graphBuilderChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "audio_graph/graph_builder")
    graphBuilderChannel.setMethodCallHandler(AudioGraphBuilderPlugin())

    val graphChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "audio_graph/graph")
    graphChannel.setMethodCallHandler(AudioGraphPlugin())

    val nodeChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "audio_graph/node")
    nodeChannel.setMethodCallHandler(AudioNodePlugin())
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method) {
      "dispose" -> {
        val id = (call.arguments as ArrayList<Any>)[0] as Int
        AudioGraph.graphs[id]?.dispose()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}

package work.ksprogram.audio_graph

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.ArrayList

/** AudioGraphPlugin */
public class AudioGraphPlugin: FlutterPlugin, MethodCallHandler {
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val fileChannel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "audio_graph/file")
    fileChannel.setMethodCallHandler(work.ksprogram.audio_graph.AudioFilePlugin())

    val graphBuilderChannel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "audio_graph/graph_builder")
    graphBuilderChannel.setMethodCallHandler(work.ksprogram.audio_graph.AudioGraphBuilderPlugin())

    val graphChannel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "audio_graph/graph")
    graphChannel.setMethodCallHandler(work.ksprogram.audio_graph.AudioGraphPlugin())

    val nodeChannel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "audio_graph/node")
    nodeChannel.setMethodCallHandler(work.ksprogram.audio_graph.AudioNodePlugin())
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method) {
      "dispose" -> {
        val id = (call.arguments as ArrayList<Any>)[0] as Int
        work.ksprogram.audio_graph.AudioGraph.Companion.graphs[id]?.dispose()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}

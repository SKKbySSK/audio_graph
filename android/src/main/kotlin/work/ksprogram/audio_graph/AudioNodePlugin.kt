package work.ksprogram.audio_graph

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import work.ksprogram.audio_graph.nodes.AudioNativeNode
import work.ksprogram.audio_graph.nodes.AudioOutputNode
import work.ksprogram.audio_graph.nodes.PlayableNode
import work.ksprogram.audio_graph.nodes.PositionableNode
import java.util.ArrayList

class AudioNodePlugin: MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = (call.arguments as ArrayList<Any>)
        val id = args[0] as Int
        val node = AudioNativeNode.nodes[id] ?: return

        when(call.method) {
            "volume" -> {
                if (node is AudioOutputNode) {
                    val volume = args[1] as Double
                    node.volume = volume
                    result.success(volume)
                    return
                }
                result.error(PluginError.invalidOperation, null, null)
            }
            "get_position" -> {
                if (node is PositionableNode) {
                    result.success(node.positionUs * 1e-6)
                    return
                }
                result.error(PluginError.invalidOperation, null, null)
            }
            "set_position" -> {
                if (node is PositionableNode) {
                    val pos = args[1] as Double
                    node.positionUs = (pos * 1e6).toLong()
                    result.success(pos)
                    return
                }
                result.error(PluginError.invalidOperation, null, null)
            }
            "prepare" -> {
                if (node is AudioOutputNode) {
                    node.prepare()
                    result.success(null)
                    return
                }
                result.error(PluginError.invalidOperation, null, null)
            }
            "play" -> {
                if (node is PlayableNode) {
                    node.play()
                    result.success(null)
                    return
                }
                result.error(PluginError.invalidOperation, null, null)
            }
            "pause" -> {
                if (node is PlayableNode) {
                    node.pause()
                    result.success(null)
                    return
                }
                result.error(PluginError.invalidOperation, null, null)
            }
            else -> result.notImplemented()
        }
    }
}

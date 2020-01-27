package work.ksprogram.audio_graph

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList

class AudioNodePlugin: MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = (call.arguments as ArrayList<Any>)
        val id = args[0] as Int
        val node = work.ksprogram.audio_graph.nodes.AudioNativeNode.nodes[id] ?: return

        when(call.method) {
            "volume" -> {
                if (node is work.ksprogram.audio_graph.nodes.AudioOutputNode) {
                    node.volume = args[1] as Double
                }
            }
            "get_position" -> {
                if (node is work.ksprogram.audio_graph.nodes.PositionableNode) {
                    result.success(node.positionUs * 1e-6)
                }
            }
            "set_position" -> {
                if (node is work.ksprogram.audio_graph.nodes.PositionableNode) {
                    node.positionUs = ((args[1] as Double) * 1e6).toLong()
                }
            }
            "prepare" -> {
                if (node is work.ksprogram.audio_graph.nodes.AudioOutputNode) {
                    node.prepare()
                }
            }
            "play" -> {
                if (node is work.ksprogram.audio_graph.nodes.PlayableNode) {
                    node.play()
                }
            }
            "pause" -> {
                if (node is work.ksprogram.audio_graph.nodes.PlayableNode) {
                    node.pause()
                }
            }
        }
    }
}
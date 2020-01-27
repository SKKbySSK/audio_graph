package com.example.audio_graph

import com.example.audio_graph.nodes.AudioNativeNode
import com.example.audio_graph.nodes.AudioOutputNode
import com.example.audio_graph.nodes.PlayableNode
import com.example.audio_graph.nodes.PositionableNode
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList

class AudioNodePlugin: MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = (call.arguments as ArrayList<Any>)
        val id = args[0] as Int
        val node = AudioNativeNode.nodes[id] ?: return

        when(call.method) {
            "volume" -> {
                if (node is AudioOutputNode) {
                    node.volume = args[1] as Double
                }
            }
            "get_position" -> {
                if (node is PositionableNode) {
                    result.success(node.positionUs * 1e-6)
                }
            }
            "set_position" -> {
                if (node is PositionableNode) {
                    node.positionUs = ((args[1] as Double) * 1e6).toLong()
                }
            }
            "prepare" -> {
                if (node is AudioOutputNode) {
                    node.prepare()
                }
            }
            "play" -> {
                if (node is PlayableNode) {
                    node.play()
                }
            }
            "pause" -> {
                if (node is PlayableNode) {
                    node.pause()
                }
            }
        }
    }
}
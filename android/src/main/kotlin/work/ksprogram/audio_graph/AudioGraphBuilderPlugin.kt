package work.ksprogram.audio_graph

import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import nodes.*
import java.util.ArrayList

class AudioGraphBuilderPlugin: MethodChannel.MethodCallHandler, AudioGraphCallback {
    override fun prepareToPlay() {

    }

    companion object {
        val mapper = jacksonObjectMapper()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "build" -> {
                val jsonGraphData = (call.arguments as ArrayList<Any>)[0] as String
                val graphModel: models.AudioGraphModel = mapper.readValue(jsonGraphData)

                var nodes: MutableList<AudioNativeNode> = mutableListOf()
                for (node in graphModel.nodes) {
                    val nativeNode = when(node.name) {
                        AudioFilePlayerNode.nodeName -> AudioFilePlayerNode(node.id, node.parameters["path"] as String)
                        AudioMixerNode.nodeName -> AudioMixerNode(node.id)
                        AudioDeviceOutputNode.nodeName -> AudioDeviceOutputNode(node.id)
                        else -> throw Error("Unknown node name")
                    }

                    if (nativeNode is AudioOutputNode) {
                        nativeNode.prepare()
                    }

                    print(nativeNode)
                    nodes.add(nativeNode)
                }

                val connections = graphModel.connections.map { AudioNodeConnection(it.key.toInt(), it.value) }
                for (connection in connections) {
                    var node = getNode(connection.input, graphModel.nodes, nodes)
                    connection.inputNode = node

                    if (connection.outputNode != null) {
                        continue
                    }

                    node = getNode(connection.output, graphModel.nodes, nodes)
                    connection.outputNode = node as AudioOutputNode
                }
                
                try {
                    for (connection in connections) {
                        if (connection.inputNode is AudioMultipleInputNode) {
                            val multipleInputNode = connection.inputNode as AudioMultipleInputNode
                            multipleInputNode.addInputNode(connection.outputNode!!)
                        }

                        if (connection.inputNode is AudioSingleInputNode) {
                            val singleInputNode = connection.inputNode as AudioSingleInputNode
                            singleInputNode.setInputNode(connection.outputNode!!)
                        }
                    }
                } catch (ex: audio.AudioException) {
                    result.error(ex.errorCode, ex.message, null)
                    return
                }

                for (node in nodes) {
                    AudioNativeNode.nodes[node.id] = node
                }

                val graph = AudioGraph(nodes)
                val id = AudioGraph.id.generateId()
                AudioGraph.graphs[id] = graph

                result.success(id)
            }
        }
    }
    
    fun getNode(pinId: Int, nodes: Iterable<models.AudioNode>, nativeNodes: Iterable<AudioNativeNode>): AudioNativeNode {
        var pinParent: models.AudioNode? = null
        for (node in nodes) {
            for (pin in node.inputs) {
                if (pin.id == pinId) {
                    pinParent = node
                    break
                }
            }

            for (pin in node.outputs) {
                if (pin.id == pinId) {
                    pinParent = node
                    break
                }
            }
        }

        for (native in nativeNodes) {
            if (native.id == pinParent!!.id) {
                return native
            }
        }

        throw Exception("Invalid graph connections")
    }
}

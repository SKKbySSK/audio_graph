package work.ksprogram.audio_graph

import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList

class AudioGraphBuilderPlugin: MethodChannel.MethodCallHandler, work.ksprogram.audio_graph.AudioGraphCallback {
    override fun prepareToPlay() {

    }

    companion object {
        val mapper = jacksonObjectMapper()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "build" -> {
                val jsonGraphData = (call.arguments as ArrayList<Any>)[0] as String
                val graphModel: work.ksprogram.audio_graph.models.AudioGraphModel = mapper.readValue(jsonGraphData)

                var nodes: MutableList<work.ksprogram.audio_graph.nodes.AudioNativeNode> = mutableListOf()
                for (node in graphModel.nodes) {
                    val nativeNode = when(node.name) {
                        work.ksprogram.audio_graph.nodes.AudioFilePlayerNode.nodeName -> work.ksprogram.audio_graph.nodes.AudioFilePlayerNode(node.id, node.parameters["path"] as String)
                        work.ksprogram.audio_graph.nodes.AudioMixerNode.nodeName -> work.ksprogram.audio_graph.nodes.AudioMixerNode(node.id)
                        work.ksprogram.audio_graph.nodes.AudioDeviceOutputNode.nodeName -> work.ksprogram.audio_graph.nodes.AudioDeviceOutputNode(node.id)
                        else -> throw Error("Unknown node name")
                    }

                    if (nativeNode is work.ksprogram.audio_graph.nodes.AudioOutputNode) {
                        nativeNode.prepare()
                    }

                    print(nativeNode)
                    nodes.add(nativeNode)
                }

                val connections = graphModel.connections.map { work.ksprogram.audio_graph.nodes.AudioNodeConnection(it.key.toInt(), it.value) }
                for (connection in connections) {
                    var node = getNode(connection.input, graphModel.nodes, nodes)
                    connection.inputNode = node

                    if (connection.outputNode != null) {
                        continue
                    }

                    node = getNode(connection.output, graphModel.nodes, nodes)
                    connection.outputNode = node as work.ksprogram.audio_graph.nodes.AudioOutputNode
                }
                
                try {
                    for (connection in connections) {
                        if (connection.inputNode is work.ksprogram.audio_graph.nodes.AudioMultipleInputNode) {
                            val multipleInputNode = connection.inputNode as work.ksprogram.audio_graph.nodes.AudioMultipleInputNode
                            multipleInputNode.addInputNode(connection.outputNode!!)
                        }

                        if (connection.inputNode is work.ksprogram.audio_graph.nodes.AudioSingleInputNode) {
                            val singleInputNode = connection.inputNode as work.ksprogram.audio_graph.nodes.AudioSingleInputNode
                            singleInputNode.setInputNode(connection.outputNode!!)
                        }
                    }
                } catch (ex: work.ksprogram.audio_graph.audio.AudioException) {
                    result.error(ex.errorCode, ex.message, null)
                    return
                }

                for (node in nodes) {
                    work.ksprogram.audio_graph.nodes.AudioNativeNode.nodes[node.id] = node
                }

                val graph = work.ksprogram.audio_graph.AudioGraph(graphModel.nodes, nodes, connections)
                val id = work.ksprogram.audio_graph.AudioGraph.Companion.id.generateId()
                work.ksprogram.audio_graph.AudioGraph.Companion.graphs[id] = graph

                result.success(id)
            }
        }
    }
    
    fun getNode(pinId: Int, nodes: Iterable<work.ksprogram.audio_graph.models.AudioNode>, nativeNodes: Iterable<work.ksprogram.audio_graph.nodes.AudioNativeNode>): work.ksprogram.audio_graph.nodes.AudioNativeNode {
        var pinParent: work.ksprogram.audio_graph.models.AudioNode? = null
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
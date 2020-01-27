package com.example.audio_graph

import com.example.audio_graph.models.AudioNode
import com.example.audio_graph.nodes.*

interface AudioGraphCallback {
    fun prepareToPlay()
}

class AudioGraph(val nodes: Iterable<AudioNode>, val nativeNodes: Iterable<AudioNativeNode>, val connections: Iterable<AudioNodeConnection>) {
    companion object {
        val graphs: MutableMap<Int, AudioGraph> = mutableMapOf()
        val id = IdManager("AudioGraph")
    }
    
    fun dispose() {
        for (node in nativeNodes) {
            AudioNativeNode.nodes.remove(node.id)?.dispose()
        }
    }
}

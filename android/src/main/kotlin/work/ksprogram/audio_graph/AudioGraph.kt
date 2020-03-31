package work.ksprogram.audio_graph

import nodes.AudioNativeNode

interface AudioGraphCallback {
    fun prepareToPlay()
}

class AudioGraph(val nodes: Iterable<AudioNativeNode>) {
    companion object {
        val graphs: MutableMap<Int, AudioGraph> = mutableMapOf()
        val id = IdManager("AudioGraph")
    }
    
    fun dispose() {
        for (node in nodes) {
            AudioNativeNode.nodes.remove(node.id)?.dispose()
        }
    }
}

package work.ksprogram.audio_graph

import work.ksprogram.audio_graph.nodes.AudioNativeNode

interface AudioGraphCallback {
    fun prepareToPlay()
}

class AudioGraph(private val nodes: Iterable<AudioNativeNode>) {
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

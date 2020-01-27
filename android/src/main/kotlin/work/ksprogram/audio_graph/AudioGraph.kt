package work.ksprogram.audio_graph

interface AudioGraphCallback {
    fun prepareToPlay()
}

class AudioGraph(val nodes: Iterable<work.ksprogram.audio_graph.models.AudioNode>, val nativeNodes: Iterable<work.ksprogram.audio_graph.nodes.AudioNativeNode>, val connections: Iterable<work.ksprogram.audio_graph.nodes.AudioNodeConnection>) {
    companion object {
        val graphs: MutableMap<Int, work.ksprogram.audio_graph.AudioGraph> = mutableMapOf()
        val id = work.ksprogram.audio_graph.IdManager("AudioGraph")
    }
    
    fun dispose() {
        for (node in nativeNodes) {
            work.ksprogram.audio_graph.nodes.AudioNativeNode.nodes.remove(node.id)?.dispose()
        }
    }
}

package work.ksprogram.audio_graph.nodes

class AudioNodeConnection(val output: Int, val input: Int) {
    var outputNode: work.ksprogram.audio_graph.nodes.AudioOutputNode? = null
    var inputNode: work.ksprogram.audio_graph.nodes.AudioNativeNode? = null
}

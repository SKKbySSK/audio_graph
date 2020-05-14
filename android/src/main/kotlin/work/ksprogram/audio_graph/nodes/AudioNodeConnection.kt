package work.ksprogram.audio_graph.nodes

class AudioNodeConnection(val output: Int, val input: Int) {
    var outputNode: AudioOutputNode? = null
    var inputNode: AudioNativeNode? = null
}

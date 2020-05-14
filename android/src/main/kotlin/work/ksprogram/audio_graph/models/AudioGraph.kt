package work.ksprogram.audio_graph.models

data class AudioGraphModel (
        val connections: Map<String, Int>,
        val nodes: List<AudioNode>
)
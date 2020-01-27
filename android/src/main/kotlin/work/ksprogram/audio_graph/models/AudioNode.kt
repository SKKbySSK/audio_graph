package work.ksprogram.audio_graph.models

data class AudioNode(
        val id: Int,
        val inputs: List<work.ksprogram.audio_graph.models.InputPin>,
        val name: String,
        val outputs: List<work.ksprogram.audio_graph.models.OutputPin>,
        val parameters: Map<String, String>,
        val volume: Double
)
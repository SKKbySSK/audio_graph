package models

data class AudioNode(
        val id: Int,
        val inputs: List<models.InputPin>,
        val name: String,
        val outputs: List<models.OutputPin>,
        val parameters: Map<String, String>,
        val volume: Double
)
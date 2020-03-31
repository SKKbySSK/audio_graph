package models

data class AudioGraphModel (
        val connections: Map<String, Int>,
        val nodes: List<models.AudioNode>
)
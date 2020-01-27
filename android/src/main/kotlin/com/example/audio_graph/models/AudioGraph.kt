package com.example.audio_graph.models

data class AudioGraphModel (
        val connections: Map<String, Int>,
        val nodes: List<AudioNode>
)
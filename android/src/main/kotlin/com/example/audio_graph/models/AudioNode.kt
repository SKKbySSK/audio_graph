package com.example.audio_graph.models

data class AudioNode(
        val id: Int,
        val inputs: List<InputPin>,
        val name: String,
        val outputs: List<OutputPin>,
        val parameters: Map<String, String>,
        val volume: Double
)
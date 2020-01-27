package com.example.audio_graph.audio

class Volume {
    companion object {
        fun applyVolume(buffer: ByteArray, volume: Double) {
            buffer.forEachIndexed { i, byte ->
                buffer[i] = (buffer[i] * volume).toByte()
            }
        }
    }
}
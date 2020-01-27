package com.example.audio_graph.audio

import android.media.MediaCodec

class AudioBuffer(val timeUs: Long, val buffer: ByteArray, val endOfStream: Boolean = false) {
    fun toBufferInfo(): MediaCodec.BufferInfo {
        val info = MediaCodec.BufferInfo()
        info.offset = 0
        info.size = buffer.size
        info.presentationTimeUs = timeUs

        return info
    }

    fun toPair(): Pair<MediaCodec.BufferInfo, ByteArray> {
        return Pair(toBufferInfo(), buffer)
    }
}
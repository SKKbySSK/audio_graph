package com.example.audio_graph.nodes

import android.media.MediaCodec
import android.media.MediaFormat
import com.example.audio_graph.audio.ManagedAudioTrack
import com.example.audio_graph.audio.ManagedAudioTrackCallback

class AudioDeviceOutputNode(id: Int) : AudioInputNode(id), AudioSingleInputNode, ManagedAudioTrackCallback, OutputNodeCallback {
    companion object {
        const val nodeName = "audio_device_output_node"
    }

    private val audioTrack: ManagedAudioTrack
    private var lastFormat: MediaFormat? = null
    private var inputNode: AudioOutputNode? = null

    init {
        audioTrack = ManagedAudioTrack(this)
    }

    override fun readyToPlay() {
        audioTrack.play()
    }

    override fun write(format: MediaFormat, info: MediaCodec.BufferInfo, buffer: ByteArray) {
        if (format != lastFormat) {
            audioTrack.outputFormatChanged(format, lastFormat)
            lastFormat = format
        }

        audioTrack.write(info, buffer)
    }

    override fun setInputNode(node: AudioOutputNode) {
        inputNode?.callback = null
        node.callback = this
        inputNode = node
    }

    override fun prepared(node: AudioOutputNode) {

    }

    override fun bufferAvailable(node: AudioOutputNode) {
        val buffer = node.nextBuffer()!!
        val format = node.getMediaFormat()

        write(format, buffer.first, buffer.second)
    }

    override fun dispose() {
        audioTrack.dispose()
        super.dispose()
    }
}
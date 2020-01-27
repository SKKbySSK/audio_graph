package work.ksprogram.audio_graph.nodes

import android.media.MediaCodec
import android.media.MediaFormat

class AudioDeviceOutputNode(id: Int) : work.ksprogram.audio_graph.nodes.AudioInputNode(id), work.ksprogram.audio_graph.nodes.AudioSingleInputNode, work.ksprogram.audio_graph.audio.ManagedAudioTrackCallback, work.ksprogram.audio_graph.nodes.OutputNodeCallback {
    companion object {
        const val nodeName = "audio_device_output_node"
    }

    private val audioTrack: work.ksprogram.audio_graph.audio.ManagedAudioTrack
    private var lastFormat: MediaFormat? = null
    private var inputNode: work.ksprogram.audio_graph.nodes.AudioOutputNode? = null

    init {
        audioTrack = work.ksprogram.audio_graph.audio.ManagedAudioTrack(this)
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

    override fun setInputNode(node: work.ksprogram.audio_graph.nodes.AudioOutputNode) {
        inputNode?.callback = null
        node.callback = this
        inputNode = node
    }

    override fun prepared(node: work.ksprogram.audio_graph.nodes.AudioOutputNode) {

    }

    override fun bufferAvailable(node: work.ksprogram.audio_graph.nodes.AudioOutputNode) {
        val buffer = node.nextBuffer()!!
        val format = node.getMediaFormat()

        write(format, buffer.first, buffer.second)
    }

    override fun dispose() {
        audioTrack.dispose()
        super.dispose()
    }
}
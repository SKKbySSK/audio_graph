package nodes

import android.media.MediaCodec
import android.media.MediaFormat

class AudioDeviceOutputNode(id: Int) : AudioInputNode(id), AudioSingleInputNode, audio.ManagedAudioTrackCallback, OutputNodeCallback {
    companion object {
        const val nodeName = "audio_device_output_node"
    }

    private val audioTrack = audio.ManagedAudioTrack(this)
    private var lastFormat: MediaFormat? = null
    private var inputNode: AudioOutputNode? = null

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
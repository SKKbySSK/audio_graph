package nodes

import android.media.MediaCodec
import android.media.MediaFormat

enum class PreparationState {
    none,
    preparing,
    prepared,
}

interface OutputNodeCallback {
    fun prepared(node: AudioOutputNode)
    fun bufferAvailable(node: AudioOutputNode)
}

abstract class AudioNativeNode(val id: Int) {
    companion object {
        val nodes: MutableMap<Int, AudioNativeNode> = mutableMapOf()
    }

    var isDisposed = false
    open fun dispose() {
        isDisposed = true
    }
}

interface PlayableNode {
    fun play()
    fun pause()
}

interface PositionableNode {
    var positionUs: Long
}

interface AudioSingleInputNode {
    fun setInputNode(node: AudioOutputNode)
}

interface AudioMultipleInputNode {
    fun addInputNode(node: AudioOutputNode)
    fun removeInputNode(node: AudioOutputNode)
}

abstract class AudioInputNode(id: Int) : AudioNativeNode(id) {
    abstract fun write(format: MediaFormat, info: MediaCodec.BufferInfo, buffer: ByteArray)
}

abstract class AudioOutputNode(id: Int) : AudioNativeNode(id) {
    abstract fun nextBuffer(): Pair<MediaCodec.BufferInfo, ByteArray>?
    abstract fun prepare()
    abstract fun getPreparationState(): PreparationState
    abstract fun getMediaFormat(): MediaFormat
    abstract fun bufferAvailable(): Boolean

    var callback: OutputNodeCallback? = null
    var volume: Double = 1.0

    override fun dispose() {
        callback = null
        super.dispose()
    }
}

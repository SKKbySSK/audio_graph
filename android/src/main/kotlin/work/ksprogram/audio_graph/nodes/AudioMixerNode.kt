package work.ksprogram.audio_graph.nodes

import android.media.MediaCodec
import android.media.MediaFormat
import work.ksprogram.audio_graph.audio.AudioFormatException
import work.ksprogram.audio_graph.audio.Volume
import java.util.*

class AudioMixerNode(id: Int) : AudioOutputNode(id), AudioMultipleInputNode, OutputNodeCallback {
    companion object {
        const val nodeName = "audio_mixer_node"
    }

    private var buffers: Queue<Pair<MediaCodec.BufferInfo, ByteArray>> = ArrayDeque()
    private var thread: Thread? = null
    private val sources: MutableList<AudioOutputNode> = mutableListOf()
    private var currentFormat: MediaFormat? = null

    private fun mixingThread() {
        while (bufferAvailable() && !isDisposed) {
            val buffers = sources.mapNotNull { it.nextBuffer() }

            if (buffers.count() > 0) {
                val minPair = buffers.minBy { it.second.size }!!
                val size = minPair.second.size
                val buf = ByteArray(size)
                var sum: Int
                for (i in 0 until size) {
                    sum = 0
                    for (b in buffers) {
                        sum += b.second[i]
                    }

                    if (sum > Byte.MAX_VALUE) {
                        buf[i] = Byte.MAX_VALUE
                    } else if (sum < Byte.MIN_VALUE) {
                        buf[i] = Byte.MIN_VALUE
                    } else {
                        buf[i] = sum.toByte()
                    }
                }

                Volume.applyVolume(buf, volume)

                this.buffers.add(Pair(minPair.first, buf))
                callback?.bufferAvailable(this)
            }
        }

        while (buffers.count() > 0 && callback != null) {
            callback?.bufferAvailable(this)
        }

        thread = null
    }

    override fun bufferAvailable(): Boolean {
        return sources.any { it.bufferAvailable() }
    }

    override fun bufferAvailable(node: AudioOutputNode) {
        if (thread == null) {
            thread = Thread {
                mixingThread()
            }
            thread?.start()
        }
    }

    override fun prepare() {
    }

    override fun prepared(node: AudioOutputNode) {
        if (sources.all { it.getPreparationState() == PreparationState.Prepared }) {
            callback?.prepared(this)
        }
    }

    override fun getPreparationState(): PreparationState {
        return if (sources.all { it.getPreparationState() == PreparationState.Prepared }) {
            PreparationState.Prepared
        } else {
            PreparationState.Preparing
        }
    }
    
    override fun nextBuffer(): Pair<MediaCodec.BufferInfo, ByteArray>? {
        return when(sources.count()) {
            0 -> null
            else -> buffers.poll()
        }
    }

    override fun getMediaFormat(): MediaFormat {
        return sources.first().getMediaFormat()
    }

    override fun addInputNode(node: AudioOutputNode) {
        if (sources.count() == 0) {
            currentFormat = node.getMediaFormat()
        } else if(!isSupportedFormat(node.getMediaFormat())) {
            throw AudioFormatException()
        }

        node.callback = this
        sources.add(node)
    }

    override fun removeInputNode(node: AudioOutputNode) {
        node.callback = null
        sources.remove(node)

        if (sources.count() == 0) {
            currentFormat = null
        }
    }

    private fun isSupportedFormat(format: MediaFormat): Boolean {
        val current = currentFormat ?: return true

        val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE) == current.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT) == current.getInteger(MediaFormat.KEY_CHANNEL_COUNT)

        return sampleRate && channels
    }

    override fun dispose() {
        sources.clear()
        buffers.clear()
        super.dispose()
    }
}

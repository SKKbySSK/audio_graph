package work.ksprogram.audio_graph.nodes

import android.media.MediaCodec
import android.media.MediaFormat
import java.util.*

class AudioMixerNode(id: Int) : work.ksprogram.audio_graph.nodes.AudioOutputNode(id), work.ksprogram.audio_graph.nodes.AudioMultipleInputNode, work.ksprogram.audio_graph.nodes.OutputNodeCallback {
    companion object {
        const val nodeName = "audio_mixer_node"
    }

    private var buffers: Queue<Pair<MediaCodec.BufferInfo, ByteArray>> = ArrayDeque<Pair<MediaCodec.BufferInfo, ByteArray>>()
    private var thread: Thread? = null
    private val sources: MutableList<work.ksprogram.audio_graph.nodes.AudioOutputNode> = mutableListOf()
    private var currentFormat: MediaFormat? = null

    fun mixingThread() {
        while (bufferAvailable() && !isDisposed) {
            val buffers = sources.mapNotNull { it.nextBuffer() }
            val length = this.sources.count()

            if (buffers.count() > 0) {
                val minPair = buffers.minBy({ it.second.size })!!
                val size = minPair.second.size
                val buf = Array(size) { i ->
                    var result = 0
                    for (b in buffers) {
                        result += b.second[i]
                    }
                    
                    result /= length
                    
                    return@Array result.toByte()
                }.toByteArray()

                work.ksprogram.audio_graph.audio.Volume.applyVolume(buf, volume)

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

    override fun bufferAvailable(node: work.ksprogram.audio_graph.nodes.AudioOutputNode) {
        if (thread == null) {
            thread = Thread {
                mixingThread()
            }
            thread?.start()
        }
    }

    override fun prepare() {
    }

    override fun prepared(node: work.ksprogram.audio_graph.nodes.AudioOutputNode) {
        if (sources.all { it.getPreparationState() == work.ksprogram.audio_graph.nodes.PreparationState.prepared }) {
            callback?.prepared(this)
        }
    }

    override fun getPreparationState(): work.ksprogram.audio_graph.nodes.PreparationState {
        if (sources.all { it.getPreparationState() == work.ksprogram.audio_graph.nodes.PreparationState.prepared }) {
            return work.ksprogram.audio_graph.nodes.PreparationState.prepared
        } else {
            return work.ksprogram.audio_graph.nodes.PreparationState.preparing
        }
    }
    
    override fun nextBuffer(): Pair<MediaCodec.BufferInfo, ByteArray>? {
        when(sources.count()) {
            0 -> return null
            else -> return buffers.poll()
        }
    }

    override fun getMediaFormat(): MediaFormat {
        return sources.first().getMediaFormat()
    }

    override fun addInputNode(node: work.ksprogram.audio_graph.nodes.AudioOutputNode) {
        if (sources.count() == 0) {
            currentFormat = node.getMediaFormat()
        } else if(!isSupportedFormat(node.getMediaFormat())) {
            throw work.ksprogram.audio_graph.audio.AudioFormatException()
        }

        node.callback = this
        sources.add(node)
    }

    override fun removeInputNode(node: work.ksprogram.audio_graph.nodes.AudioOutputNode) {
        node.callback = null
        sources.remove(node)

        if (sources.count() == 0) {
            currentFormat = null
        }
    }

    private fun isSupportedFormat(format: MediaFormat): Boolean {
        val current = currentFormat
        if (current == null) {
            return true
        }

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
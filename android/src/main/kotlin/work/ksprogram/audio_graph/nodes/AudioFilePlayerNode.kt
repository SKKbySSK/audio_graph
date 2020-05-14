package work.ksprogram.audio_graph.nodes

import android.media.MediaCodec
import android.media.MediaFormat
import work.ksprogram.audio_graph.audio.*
import java.util.*

class AudioFilePlayerNode(id: Int, path: String, bufferDurationSeconds: Double = 0.2, private val maximumBufferCount: Int = 5): AudioOutputNode(id), PlayableNode, PositionableNode, AudioFileDecoderCallback, BufferSinkCallback {
    companion object {
        const val nodeName = "audio_file_player_node"
    }

    private var buffers: Queue<AudioBuffer> = ArrayDeque()
    private var format: MediaFormat? = null
    private var preparationState: PreparationState = PreparationState.None
    private var bufferSink: BufferSink
    private val decoder: AudioFileDecoder = AudioFileDecoder(path, this)

    private var isPlaying = false

    private var _posUs: Long = 0
    override var positionUs: Long
        get() { return _posUs }
        set(value) {
            buffers.clear()
            bufferSink.reset()
            _posUs = value
            decoder.seekTo(value)
            decoder.resume()
        }

    init {
        val bufferSize = decoder.bps.toDouble() / 8.0 * bufferDurationSeconds
        bufferSink = BufferSink(bufferSize.toInt(), decoder.bps, this)
        decoder.beginDecoding()
    }

    override fun prepare() {
        preparationState = PreparationState.Preparing
    }

    override fun decoded(info: MediaCodec.BufferInfo, data: ByteArray) {
        val eos = info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0
        bufferSink.append(AudioBuffer(info.presentationTimeUs, data))
    }
    
    override fun buffered(sink: BufferSink, buffer: AudioBuffer) {
        buffers.add(buffer)
        if (isPlaying) {
            callback?.bufferAvailable(this)
        }

        if (buffers.count() > maximumBufferCount) {
            decoder.pause()
        }
    }

    override fun decoderTimedOut() {
    }

    override fun outputFormatChanged(format: MediaFormat, lastFormat: MediaFormat?) {
        if (lastFormat != null) {
            val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE) != format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            val channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT) != format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)

            if (sampleRate || channels) {
                println("unsupported format changing")
            }
        }

        bufferSink.setFormat(decoder.bps)
        this.format = format
    }

    override fun prepared() {
        preparationState = PreparationState.Prepared
        callback?.prepared(this)
    }
    
    override fun nextBuffer(): Pair<MediaCodec.BufferInfo, ByteArray>? {
        if (isPlaying) {
            val buffer = buffers.poll()
            if (buffer != null) {
                Volume.applyVolume(buffer.buffer, volume)
                _posUs = buffer.timeUs
            }

            if (buffers.count() > 0) {
                callback?.bufferAvailable(this)
            }

            if (buffers.count() < maximumBufferCount) {
                decoder.resume()
            }

            return buffer?.toPair()
        }

        return null
    }

    override fun getMediaFormat(): MediaFormat {
        return this.format ?: decoder.format
    }

    override fun getPreparationState(): PreparationState {
        return preparationState
    }

    override fun bufferAvailable(): Boolean {
        return buffers.count() > 0
    }

    override fun play() {
        isPlaying = true
        if (buffers.count() > 0) {
            callback?.bufferAvailable(this)
        }
    }

    override fun pause() {
        isPlaying = false
    }

    override fun dispose() {
        pause()
        decoder.dispose()
        bufferSink.reset()
        buffers.clear()
        super.dispose()
    }
}
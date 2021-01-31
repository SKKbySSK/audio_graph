package work.ksprogram.audio_graph.audio

import java.util.*
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock
import kotlin.math.min

interface BufferSinkCallback {
    fun buffered(sink: BufferSink, buffer: AudioBuffer)
}

class BufferSink(private val size: Int, bps: Int, private val callback: BufferSinkCallback) {
    private var currentBuffer: AudioBuffer? = null
    private val leftOvers: ArrayDeque<Byte> = ArrayDeque()
    private var fillOffset: Int = 0
    private var bpus: Double // bytes per microsec
    private val lock = ReentrantLock()

    init {
        val bytesPerSec = bps / 8
        bpus = bytesPerSec / 1e6
    }

    fun setFormat(bps: Int) {
        val bytesPerSec = bps / 8
        bpus = bytesPerSec / 1e6
    }

    fun reset() {
        lock.withLock {
            leftOvers.clear()
            currentBuffer = null
        }
    }

    // TODO: handle end of stream (last buffer won't be passed to the callback)
    fun append(buffer: AudioBuffer) {
        lock.withLock {
            appendInternal(buffer)
        }
    }

    private fun appendInternal(buffer: AudioBuffer) {
        var fill = min(size - fillOffset, leftOvers.count())

        // Generate or get next audio buffer
        val currentBuffer: AudioBuffer
        if (this.currentBuffer == null) {
            val timeUs: Long
            timeUs = if (leftOvers.count() > 0) {
                val delta = fill * bpus
                buffer.timeUs - delta.toLong()
            } else {
                buffer.timeUs
            }

            currentBuffer = AudioBuffer(timeUs, ByteArray(size))
            this.currentBuffer = currentBuffer
        } else {
            currentBuffer = this.currentBuffer!!
        }

        // fill the audio buffer with the last left overs
        for (i in 0 until fill) {
            currentBuffer.buffer[fillOffset++] = leftOvers.remove()
        }

        fill = min(currentBuffer.buffer.size - fillOffset, buffer.buffer.size)

        for (i in buffer.buffer.indices) {
            if (i < fill) {
                currentBuffer.buffer[fillOffset++] = buffer.buffer[i]
            } else {
                leftOvers.add(buffer.buffer[i])
            }
        }

        if (fillOffset == size) {
            callback.buffered(this, currentBuffer)
            this.currentBuffer = null
            fillOffset = 0
        }
    }

    fun flush() {
        val buffer = currentBuffer ?: return
        callback.buffered(this, buffer)
        this.currentBuffer = null
        fillOffset = 0
    }
}

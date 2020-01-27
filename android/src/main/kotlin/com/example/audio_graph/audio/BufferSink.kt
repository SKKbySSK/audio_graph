package com.example.audio_graph.audio

import android.provider.MediaStore
import java.util.*
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

interface BufferSinkCallback {
    fun buffered(sink: BufferSink, buffer: AudioBuffer)
}

class BufferSink(val size: Int, val bps: Int, val callback: BufferSinkCallback) {
    private var currentBuffer: AudioBuffer? = null
    private val leftOvers: ArrayDeque<Byte> = ArrayDeque()
    private var index: Int = 0
    private var totalWrite: Int = 0
    private var bpus: Double // bytes per microsec
    private var ignoreCount: Long = 0
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
            totalWrite = 0
            ignoreCount = 0
        }
    }

    fun ignore(count: Long) {
        ignoreCount += count
    }

    // TODO: handle end of stream (last buffer won't be passed to the callback)
    fun append(buffer: AudioBuffer) {
        lock.withLock {
            appendInternal(buffer)
        }
    }

    private fun appendInternal(buffer: AudioBuffer) {
        var fill = Math.min(size - index, leftOvers.count())

        val currentBuffer: AudioBuffer
        if (this.currentBuffer == null) {
            val timeUs: Long
            if (leftOvers.count() > 0) {
                val delta = fill * bpus
                timeUs = buffer.timeUs - delta.toLong()
            } else {
                timeUs = buffer.timeUs
            }

            currentBuffer = AudioBuffer(timeUs, ByteArray(size))
            this.currentBuffer = currentBuffer

        } else {
            currentBuffer = this.currentBuffer!!
        }

        for (i in 0 until fill) {
            if (ignoreCount > 0) {
                ignoreCount--
                continue
            }

            currentBuffer.buffer[index++] = leftOvers.remove()
            totalWrite++
        }
        totalWrite += fill

        fill = Math.min(currentBuffer.buffer.size - index, buffer.buffer.size)

        for (i in buffer.buffer.indices) {
            if (ignoreCount > 0) {
                ignoreCount--
                continue
            }

            if (i < fill) {
                currentBuffer.buffer[index++] = buffer.buffer[i]
            } else {
                leftOvers.add(buffer.buffer[i])
            }
            totalWrite++
        }

        if (index == size) {
            callback.buffered(this, currentBuffer)
            this.currentBuffer = null
            index = 0
        }
    }

    fun flush() {
        val buffer = currentBuffer
        if (buffer == null) {
            return
        }
        callback.buffered(this, buffer)
        this.currentBuffer = null
        index = 0
    }
}

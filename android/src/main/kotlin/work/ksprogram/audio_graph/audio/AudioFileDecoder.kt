package audio

import android.media.*
import java.lang.Exception
import java.nio.ByteBuffer
import android.media.MediaCodec
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock



interface AudioFileDecoderCallback {
    fun outputFormatChanged(format: MediaFormat, lastFormat: MediaFormat?)
    fun decoded(info: MediaCodec.BufferInfo, data: ByteArray)
    fun decoderTimedOut()
    fun prepared()
}

// https://github.com/taehwandev/MediaCodecExample/blob/master/src/net/thdev/mediacodecexample/decoder/AudioDecoderThread.java
// https://github.com/mafshin/MediaCodecDemo/blob/master/src/io/vec/demo/mediacodec/DecodeActivity.java
class AudioFileDecoder(val path: String, val callback: audio.AudioFileDecoderCallback, val timeoutUs: Long = 1000) {
    private var mediaCodec: MediaCodec
    private val mediaExtractor: MediaExtractor
    private var bufferIndex: Int = 0
    private val decoder: Runnable
    private var decoderThread: Thread
    private var totalWrittenBytes = 0
    private var disposed = false
    private var lastFormat: MediaFormat? = null
    private var seeked = false
    private var lastOffset: Long = 0
    private var startMs: Long = 0
    private val lock = ReentrantLock()
    private var paused = false
    private var needsRestart = false

    val format: MediaFormat
    val bitRate: Int
    var bps: Int //bits per second

    init {
        mediaExtractor = MediaExtractor()
        mediaExtractor.setDataSource(path)
        mediaExtractor.selectTrack(0)
        format = mediaExtractor.getTrackFormat(0)
        
        // see https://developer.android.com/reference/android/media/MediaCodec.html DataTypes/Raw Audio Buffers
        format.setInteger(MediaFormat.KEY_PCM_ENCODING, AudioFormat.ENCODING_PCM_16BIT)
        bitRate = 16

        val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        bps = sampleRate * channels * bitRate
        
        val codec = MediaCodecList(MediaCodecList.REGULAR_CODECS).findDecoderForFormat(format)
        val mediaCodec = MediaCodec.createByCodecName(codec)
        mediaCodec.configure(format, null, null, 0)
        mediaCodec.start()

        this.mediaCodec = mediaCodec

        decoder = Runnable {
            try {
                decode()
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }

        decoderThread = Thread(decoder)
    }

    fun beginDecoding() {
        decoderThread.start()
    }

    fun seekTo(timeUs: Long) {
        seeked = true
        lock.withLock {
            mediaExtractor.seekTo(timeUs, MediaExtractor.SEEK_TO_CLOSEST_SYNC)
        }

        lastOffset = mediaExtractor.sampleTime / 1000
        startMs = System.currentTimeMillis()
    }

    private fun decode() {
        startMs = System.currentTimeMillis()

        while (!disposed) {
            try {
                if (paused) {
                    Thread.sleep(10)
                    continue
                }

                if (needsRestart) {
                    if (!seeked) {
                        Thread.sleep(10)
                        continue
                    }
                    mediaCodec.stop()
                    mediaCodec.release()

                    val codec = MediaCodecList(MediaCodecList.REGULAR_CODECS).findDecoderForFormat(format)
                    val mediaCodec = MediaCodec.createByCodecName(codec)
                    mediaCodec.configure(format, null, null, 0)
                    mediaCodec.start()
                    this.mediaCodec = mediaCodec
                    needsRestart = false
                    seeked = false
                }

                processBuffer()
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }
    }

    private fun processBuffer() {
        lock.withLock {
            bufferIndex = mediaCodec.dequeueInputBuffer(timeoutUs)
            if (bufferIndex < 0) {
                return
            }

            val buffer = mediaCodec.getInputBuffer(bufferIndex) ?: return
            val sampleSize = mediaExtractor.readSampleData(buffer, 0)

            if (0 > sampleSize) {
                mediaCodec.queueInputBuffer(bufferIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
            } else {
                mediaCodec.queueInputBuffer(bufferIndex, 0, sampleSize, mediaExtractor.sampleTime, 0)
                mediaExtractor.advance()
            }
        }

        seeked = false
        val bufferInfo = MediaCodec.BufferInfo()
        val outIndex = mediaCodec.dequeueOutputBuffer(bufferInfo, timeoutUs)
        lastOffset = bufferInfo.presentationTimeUs

        when (outIndex) {
            MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                val format = mediaCodec.outputFormat
                val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                val channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                bps = sampleRate * channels * bitRate

                callback.outputFormatChanged(format, lastFormat)
                lastFormat = mediaCodec.outputFormat
            }
            MediaCodec.INFO_TRY_AGAIN_LATER -> { callback.decoderTimedOut() }
            MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED ->{}
            else -> {
                if (outIndex >= 0) {
                    val output = mediaCodec.getOutputBuffer(outIndex) as ByteBuffer
                    val buffer = ByteArray(bufferInfo.size)
                    totalWrittenBytes += bufferInfo.size
                    output.get(buffer)
                    output.clear()

                    mediaCodec.releaseOutputBuffer(outIndex, false)
                    callback.decoded(bufferInfo, buffer)
                }
            }
        }

        if (totalWrittenBytes >= format.getInteger(MediaFormat.KEY_SAMPLE_RATE) * 3) {
            callback.prepared()
        }

        if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
            needsRestart = true
        }
    }

    fun pause() {
        paused = true
    }

    fun resume() {
        paused = false
    }

    fun dispose() {
        disposed = true
        decoderThread.join()
        finalize()
    }

    private fun finalize() {
        mediaCodec.stop()
        mediaCodec.release()

        mediaExtractor.release()
    }
}
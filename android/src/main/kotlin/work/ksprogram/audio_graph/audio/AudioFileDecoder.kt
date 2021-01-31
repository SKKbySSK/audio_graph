package work.ksprogram.audio_graph.audio

import android.media.*
import java.lang.Exception
import java.nio.ByteBuffer
import android.media.MediaCodec
import android.util.Log
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

interface AudioFileDecoderCallback {
    fun outputFormatChanged(format: MediaFormat, lastFormat: MediaFormat?)
    fun decoded(info: MediaCodec.BufferInfo, data: ByteArray)
    fun decoderTimedOut()
}

// https://github.com/taehwandev/MediaCodecExample/blob/master/src/net/thdev/mediacodecexample/decoder/AudioDecoderThread.java
// https://github.com/mafshin/MediaCodecDemo/blob/master/src/io/vec/demo/mediacodec/DecodeActivity.java
class AudioFileDecoder(path: String, private val callback: AudioFileDecoderCallback, private val timeoutUs: Long = 1000) {
    private var mediaCodec: MediaCodec
    private val mediaExtractor = MediaExtractor()
    private var bufferIndex: Int = 0
    private val decoder: Runnable
    private var decoderThread: Thread? = null
    private var disposed = false
    private var lastFormat: MediaFormat? = null
    private var seeking = false
    private var lastOffset: Long = 0
    private val lock = ReentrantLock()
    private var paused = false
    private var needsRestart = false

    val format: MediaFormat
    var bitsPerSecond: Int

    init {
        mediaExtractor.setDataSource(path)
        mediaExtractor.selectTrack(0)
        format = mediaExtractor.getTrackFormat(0)
        
        // see https://developer.android.com/reference/android/media/MediaCodec.html DataTypes/Raw Audio Buffers
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            format.setInteger(MediaFormat.KEY_PCM_ENCODING, AudioFormat.ENCODING_PCM_16BIT)
        }

        val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        val bitRate = getBitRate(format)
        bitsPerSecond = sampleRate * channels * bitRate
        Log.i("AudioFileDecoder", "Format: ${sampleRate}Hz, ${channels}ch, ${bitRate}bits")
        
        val codec = MediaCodecList(MediaCodecList.ALL_CODECS).findDecoderForFormat(format)
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
    }

    fun beginDecoding() {
        if (decoderThread?.isAlive == true) {
            return
        }

        Log.i("AudioFileDecoder", "Decoder thread started")
        val thread = Thread(decoder)
        decoderThread = thread
        thread.start()
    }

    fun seekTo(timeUs: Long) {
        seeking = true
        lock.withLock {
            mediaExtractor.seekTo(timeUs, MediaExtractor.SEEK_TO_CLOSEST_SYNC)
        }

        lastOffset = mediaExtractor.sampleTime / 1000
    }

    private fun decode() {
        while (!disposed) {
            if (paused) {
                Thread.sleep(10)
                continue
            }

            // When sought or tha last buffer has BUFFER_FLAG_END_OF_STREAM flag
            if (needsRestart) {
                if (!seeking) {
                    // Wait until seeking is completed
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
                seeking = false

                Log.i("AudioFileDecoder", "MediaCodec restarted")
            }

            lock.withLock {
                fillMediaCodec()
            }

            seeking = false
            decodeBuffer()
        }
    }

    private fun fillMediaCodec() {
        bufferIndex = mediaCodec.dequeueInputBuffer(timeoutUs)
        if (bufferIndex < 0) {
            return
        }

        val buffer = mediaCodec.getInputBuffer(bufferIndex) ?: return
        val sampleSize = mediaExtractor.readSampleData(buffer, 0)

        if (0 >= sampleSize) {
            mediaCodec.queueInputBuffer(bufferIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
        } else {
            mediaCodec.queueInputBuffer(bufferIndex, 0, sampleSize, mediaExtractor.sampleTime, 0)
            mediaExtractor.advance()
        }
    }

    private fun decodeBuffer() {
        val bufferInfo = MediaCodec.BufferInfo()
        val outIndex = mediaCodec.dequeueOutputBuffer(bufferInfo, timeoutUs)
        lastOffset = bufferInfo.presentationTimeUs

        when (outIndex) {
            MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                val format = mediaCodec.outputFormat
                val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                val channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                val bitRate = getBitRate(format)
                Log.i("AudioFileDecoder", "Format changed to ${sampleRate}Hz, ${channels}ch, ${bitRate}bits")
                bitsPerSecond = sampleRate * channels * bitRate

                if (!seeking) {
                    lastFormat = mediaCodec.outputFormat
                    callback.outputFormatChanged(format, lastFormat)
                }
            }
            MediaCodec.INFO_TRY_AGAIN_LATER -> {
                if (!seeking) {
                    callback.decoderTimedOut()
                }
            }
            MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED ->{}
            else -> {
                if (outIndex >= 0) {
                    val output = mediaCodec.getOutputBuffer(outIndex) as ByteBuffer
                    val buffer = ByteArray(bufferInfo.size)
                    output.get(buffer)
                    output.clear()

                    mediaCodec.releaseOutputBuffer(outIndex, false)

                    if (!seeking) {
                        callback.decoded(bufferInfo, buffer)
                    }
                }
            }
        }

        if (seeking) {
            return
        }

        if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
            needsRestart = true
            Log.i("AudioFileDecoder", "Reach end of stream")
        }
    }

    private fun getBitRate(format: MediaFormat): Int {
        val pcm = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            format.getInteger(MediaFormat.KEY_PCM_ENCODING)
        } else {
            AudioFormat.ENCODING_PCM_16BIT
        }

        return when (pcm) {
            AudioFormat.ENCODING_PCM_16BIT -> 16
            AudioFormat.ENCODING_PCM_8BIT -> 8
            AudioFormat.ENCODING_PCM_FLOAT -> 32
            else -> 0
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
        decoderThread?.join()
        finalize()
    }

    private fun finalize() {
        mediaCodec.stop()
        mediaCodec.release()

        mediaExtractor.release()
    }
}
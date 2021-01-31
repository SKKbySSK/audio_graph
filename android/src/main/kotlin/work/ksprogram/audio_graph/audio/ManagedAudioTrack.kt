package work.ksprogram.audio_graph.audio

import android.media.*

interface ManagedAudioTrackCallback {
    fun readyToPlay()
}

class ManagedAudioTrack(private val callback: ManagedAudioTrackCallback, private val bufferDuration: Int = 5) {
    private var track: AudioTrack? = null
    private var format: AudioFormat? = null
    private var minimumBytes: Int = 0
    private var bytesWritten: Int = 0
    private var useShortArray = true
    private var ready = false

    fun outputFormatChanged(format: MediaFormat, lastFormat: MediaFormat?) {
        if (lastFormat == null) {
            val attrs = AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA).setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build()

            val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            val audio = AudioFormat.Builder().setSampleRate(sampleRate).setEncoding(AudioFormat.ENCODING_PCM_16BIT).setChannelMask(AudioFormat.CHANNEL_OUT_STEREO).build()

            val size = AudioTrack.getMinBufferSize(audio.sampleRate, audio.channelMask, audio.encoding)
            useShortArray = (audio.encoding == AudioFormat.ENCODING_PCM_16BIT)

            this.format = audio
            track = AudioTrack(attrs, audio, size, AudioTrack.MODE_STREAM, AudioManager.AUDIO_SESSION_ID_GENERATE)

            minimumBytes = size * bufferDuration
        }

        track?.playbackRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
    }

    fun write(info: MediaCodec.BufferInfo, data: ByteArray) {
        val writeResult = if (useShortArray) {
            val shortData = ShortArray(data.size / 2) {
                (data[it * 2] + (data[(it * 2) + 1].toInt() shl 8)).toShort()
            }
            track!!.write(shortData, info.offset / 2, info.size / 2)
        } else {
            track!!.write(data, info.offset, info.size)
        }

        if (writeResult >= 0) {
            if (ready) return
            bytesWritten += info.size

            if (bytesWritten >= minimumBytes) {
                ready = true
                callback.readyToPlay()
            }
        } else {
            println("Error : $writeResult")
        }
    }

    fun discardBuffer() {
        // https://developer.android.com/reference/android/media/AudioTrack.html#flush%28%29
        val track = this.track ?: return
        track.pause()
        track.flush()

        bytesWritten = 0
        ready = false
    }

    fun play() {
        track?.play()
    }

    fun dispose() {
        track?.release()
        track = null
    }
}

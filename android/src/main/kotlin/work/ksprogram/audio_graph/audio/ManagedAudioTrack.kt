package work.ksprogram.audio_graph.audio

import android.media.*

interface ManagedAudioTrackCallback {
    fun readyToPlay()
}

class ManagedAudioTrack(val callback: work.ksprogram.audio_graph.audio.ManagedAudioTrackCallback, val bufferDuration: Int = 5) {
    private var track: AudioTrack? = null
    private var format: AudioFormat? = null
    private var minimumBytes: Int = 0
    private var bytesWritten: Int = 0
    private var ready = false

    fun outputFormatChanged(format: MediaFormat, lastFormat: MediaFormat?) {
        if (lastFormat == null) {
            val attrs = AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA).setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build()

            val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            val audio = AudioFormat.Builder().setSampleRate(sampleRate).setEncoding(AudioFormat.ENCODING_PCM_16BIT).setChannelMask(AudioFormat.CHANNEL_OUT_STEREO).build()

            val size = AudioTrack.getMinBufferSize(audio.sampleRate, audio.channelMask, AudioFormat.ENCODING_PCM_16BIT)

            this.format = audio
            track = AudioTrack(attrs, audio, size, AudioTrack.MODE_STREAM, AudioManager.AUDIO_SESSION_ID_GENERATE)

            minimumBytes = size * bufferDuration
        }

        track?.playbackRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
    }

    fun write(info: MediaCodec.BufferInfo, data: ByteArray) {
        val write = track!!.write(data, info.offset, info.offset + info.size)
        if (write >= 0) {
            if (ready) return
            bytesWritten += data.size
            if (bytesWritten > minimumBytes) {
                ready = true
                callback.readyToPlay()
            }
        } else {
            println("Error : $write")
        }
    }

    fun play() {
        track?.play()
    }
    
    fun pause() {
        track?.pause()
    }

    fun dispose() {
        track?.release()
        track = null
    }
}

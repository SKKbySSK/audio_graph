package work.ksprogram.audio_graph.audio

import java.lang.IllegalArgumentException

class Volume {
    companion object {
        fun applyVolume(buffer: ByteArray, volume: Double) {
            if (volume > 1 || volume < 0) {
                throw IllegalArgumentException("Volume must be between 0 to 1")
            } else if (volume == 1.0) {
                return
            }

            for(i in buffer.indices) {
                buffer[i] = (buffer[i] * volume).toByte()
            }
        }
    }
}
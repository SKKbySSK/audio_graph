package work.ksprogram.audio_graph.audio

import work.ksprogram.audio_graph.models.AudioFormat

class AudioMixer {
    companion object {
        fun mixInterleaved(buffers: Iterable<ByteArray>): ByteArray {
            var size = 0
            for (buffer in buffers) {
                if (buffer.size > size) {
                    size = buffer.size
                }
            }

            val destinationInt = IntArray(size)
            for (buffer in buffers) {
                for (i in buffer.indices) {
                    destinationInt[i] += buffer[i].toInt()
                }
            }

            val dest = ByteArray(size)
            var value: Int
            for (i in 0 until size) {
                value = destinationInt[i]
                if (value > Byte.MAX_VALUE) {
                    dest[i] = Byte.MAX_VALUE
                } else if (value < Byte.MIN_VALUE) {
                    dest[i] = Byte.MIN_VALUE
                } else {
                    dest[i] = value.toByte()
                }
            }

            return dest
        }
    }
}

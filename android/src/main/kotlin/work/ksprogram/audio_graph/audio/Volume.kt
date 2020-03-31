package audio

class Volume {
    companion object {
        fun applyVolume(buffer: ByteArray, volume: Double) {
            buffer.forEachIndexed { i, byte ->
                buffer[i] = (byte * volume).toByte()
            }
        }
    }
}
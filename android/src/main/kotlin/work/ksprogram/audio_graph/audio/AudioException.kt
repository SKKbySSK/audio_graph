package work.ksprogram.audio_graph.audio

open class AudioException(val errorCode: String, message: String): Exception(message) {

}

class AudioFormatException(message: String = "Invalid format error") : work.ksprogram.audio_graph.audio.AudioException("ERR_FORMAT", message) {

}
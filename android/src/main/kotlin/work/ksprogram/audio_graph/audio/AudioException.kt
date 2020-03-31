package audio

open class AudioException(val errorCode: String, message: String): Exception(message)

class AudioFormatException(message: String = "Invalid format error") : audio.AudioException("ERR_FORMAT", message)
package com.example.audio_graph.audio

open class AudioException(val errorCode: String, message: String): Exception(message) {

}

class AudioFormatException(message: String = "Invalid format error") : AudioException("ERR_FORMAT", message) {

}
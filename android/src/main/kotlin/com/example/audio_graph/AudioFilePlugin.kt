package com.example.audio_graph

import android.media.MediaExtractor
import android.media.MediaFormat
import com.example.audio_graph.models.AudioFormat
import com.google.gson.Gson
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList

class AudioFilePlugin: MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "get_duration" -> {
                val extractor = MediaExtractor()
                val path = (call.arguments as ArrayList<Any>)[0] as String
                extractor.setDataSource(path)
                val format = extractor.getTrackFormat(0)
                val durationSec = format.getLong(MediaFormat.KEY_DURATION) * 1e-6
                result.success(durationSec)
            }
            "get_format" -> {
                val extractor = MediaExtractor()
                val path = (call.arguments as ArrayList<Any>)[0] as String
                extractor.setDataSource(path)
                val format = extractor.getTrackFormat(0)
                val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                val channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                result.success(Gson().toJson(AudioFormat(channels, sampleRate)))
            }
        }
    }
}
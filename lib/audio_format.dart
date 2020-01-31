/// AudioFormat defines the format of the audio source
class AudioFormat {
  const AudioFormat(this.sampleRate, this.channels);
  const AudioFormat.any()
      : this.sampleRate = 0,
        this.channels = 0;

  /// Sample rate in Hz
  final int sampleRate;

  /// Channel count
  final int channels;

  AudioFormat.fromJson(Map<String, dynamic> json)
      : sampleRate = json['sample_rate'],
        channels = json['channels'];

  Map<String, dynamic> toJson() {
    return {
      'sample_rate': sampleRate,
      'channels': channels,
    };
  }

  @override
  bool operator ==(Object format) {
    if (format is AudioFormat && format != null) {
      return sampleRate == format.sampleRate && channels == format.channels;
    }

    return false;
  }

  @override
  int get hashCode => (sampleRate * channels).hashCode;
}

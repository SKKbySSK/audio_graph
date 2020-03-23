/// AudioFormat defines the format of the audio source
class AudioFormat {
  const AudioFormat(this.sampleRate, this.channels);
  const AudioFormat.any()
      : sampleRate = 0,
        channels = 0;

  AudioFormat.fromJson(Map<String, dynamic> json)
      : sampleRate = json['sample_rate'] as int,
        channels = json['channels'] as int;

  /// Sample rate in Hz
  final int sampleRate;

  /// Channel count
  final int channels;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sample_rate': sampleRate,
      'channels': channels,
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is AudioFormat) {
      return sampleRate == other.sampleRate && channels == other.channels;
    }

    return false;
  }

  @override
  int get hashCode => (sampleRate * channels).hashCode;
}

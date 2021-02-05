//
//  AudioFileNodePlugin.swift
//  audio_graph
//
//  Created by Kaisei Sunaga on 2020/01/24.
//

import Foundation
import Flutter
import AVFoundation

public class AudioFileNodePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let path = (call.arguments as? [String])?.first else {
      result(PluginError.createInvalidOperation(message: "There is no argument"))
      return
    }
    
    let file = try! AVAudioFile(forReading: URL(fileURLWithPath: path))
    switch call.method {
    case "get_format":
      let format = AudioFormat(sampleRate: Int(file.processingFormat.sampleRate), channels: Int(file.processingFormat.channelCount))
      let json = try! JSONEncoder().encode(format)
      result(String(data: json, encoding: .utf8))
    case "get_duration":
      result(Double(file.length) / file.processingFormat.sampleRate)
    default:
      result(FlutterMethodNotImplemented)
      break;
    }
  }
}

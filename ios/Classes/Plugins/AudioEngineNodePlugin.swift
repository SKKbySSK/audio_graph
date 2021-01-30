//
//  AudioEngineNodePlugin.swift
//  audio_graph
//
//  Created by Kaisei Sunaga on 2020/01/24.
//

import Foundation
import Flutter

class AudioEngineNodePlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
  }
  
  static var nodes: [Int: AudioEngineNode] = [:]
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [Any],
          let nodeId = args[0] as? Int, let node = AudioEngineNodePlugin.nodes[nodeId] else { return }
    
    switch call.method {
    case "volume":
      let volume: Double = args[1] as! Double
      guard let volNode = node as? AudioVolumeEditableNode else { return }
      volNode.volume = volume
    default:
      break
    }
    
    switch call.method {
    case "get_position":
      guard let posNode = node as? AudioPositionableNode else { return }
      let pos = posNode.position
      result(pos)
    case "set_position":
      let pos: Double = args[1] as! Double
      guard let posNode = node as? AudioPositionableNode else { return }
      posNode.position = pos;
    default:
      break
    }
    
    switch call.method {
    case "prepare":
      guard let preNode = node as? AudioPreparableNode else { return }
      preNode.prepare()
    default:
      break
    }
    
    guard let controllable = node as? AudioControllableNode else { return }
    switch call.method {
    case "play":
      controllable.play()
    case "pause":
      controllable.pause()
    default:
      break
    }
  }
}

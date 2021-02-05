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
    guard let args = call.arguments as? [Any], let nodeId = args[0] as? Int else {
      result(PluginError.createInvalidOperation(message: "There is no argument"))
      return
    }
    
    guard let node = AudioEngineNodePlugin.nodes[nodeId] else {
      result(PluginError.createNodeNotFound())
      return
    }
    
    let invalidOpeError = PluginError.createInvalidOperation(message: "The node does not support \(call.method) method")
    
    switch call.method {
    case "volume":
      let volume: Double = args[1] as! Double
      guard let volNode = node as? AudioVolumeEditableNode else {
        result(invalidOpeError)
        return
      }
      
      volNode.volume = volume
      result(volume)
      return
    default:
      break
    }
    
    switch call.method {
    case "get_position":
      guard let posNode = node as? AudioPositionableNode else {
        result(invalidOpeError)
        return
      }
      
      let pos = posNode.position
      result(pos)
      return
    case "set_position":
      let pos: Double = args[1] as! Double
      guard let posNode = node as? AudioPositionableNode else {
        result(invalidOpeError)
        return
      }
      
      posNode.position = pos;
      result(pos)
      return
    default:
      break
    }
    
    switch call.method {
    case "prepare":
      guard let preNode = node as? AudioPreparableNode else {
        result(invalidOpeError)
        return
      }
      
      preNode.prepare()
      result(nil)
      return
    default:
      break
    }
    
    switch call.method {
    case "play":
      guard let controllable = node as? AudioControllableNode else {
        result(invalidOpeError)
        return
      }
      
      controllable.play()
      result(nil)
      return
    case "pause":
      guard let controllable = node as? AudioControllableNode else {
        result(invalidOpeError)
        return
      }
      
      controllable.pause()
      result(nil)
      return
    default:
      break
    }
    
    result(FlutterMethodNotImplemented)
  }
}

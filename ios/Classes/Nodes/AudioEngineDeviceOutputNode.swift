//
//  AudioEngineDeviceOutputNode.swift
//  audio_graph
//
//  Created by Kaisei Sunaga on 2020/01/31.
//

import Foundation
import AVFoundation

class AudioEngineDeviceOutputNode: AudioEngineNode {
  static let nodeName = "audio_device_output_node"
  
  let node: AudioNode
  let engineNode: AVAudioNode
  let inputConnections: [AudioNodeConnection]
  let outputConnections: [AudioNodeConnection]
  let shouldAttach: Bool = false
  
  init(_ node: AudioNode, engine: AVAudioEngine, inputConnections: [AudioNodeConnection], outputConnections: [AudioNodeConnection]) throws {
    guard node.name == AudioEngineDeviceOutputNode.nodeName else { throw NSError() }
    self.node = node
    self.inputConnections = inputConnections
    self.outputConnections = outputConnections
    
    for (index, input) in inputConnections.enumerated() {
      input.inBus = index
    }
    
    engineNode = engine.mainMixerNode
  }
}

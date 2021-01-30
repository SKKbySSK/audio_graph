//
//  AudioEngineMixerNode.swift
//  audio_graph
//
//  Created by Kaisei Sunaga on 2020/01/31.
//

import Foundation
import AVFoundation

class AudioEngineMixerNode: AudioEngineNode, AudioVolumeEditableNode {
  static let nodeName = "audio_mixer_node"
  
  var node: AudioNode
  let engineNode: AVAudioNode
  let inputConnections: [AudioNodeConnection]
  let outputConnections: [AudioNodeConnection]
  let shouldAttach: Bool = true
  
  var volume: Double {
    didSet {
      node.volume = volume
      (engineNode as! AVAudioMixerNode).outputVolume = Float(volume)
    }
  }
  
  
  init(_ node: AudioNode, inputConnections: [AudioNodeConnection], outputConnections: [AudioNodeConnection]) throws {
    guard node.name == AudioEngineMixerNode.nodeName else { throw NSError() }
    self.node = node
    self.inputConnections = inputConnections
    self.outputConnections = outputConnections
    
    let mixer = AVAudioMixerNode()
    mixer.volume = Float(node.volume)
    for (i, con) in inputConnections.enumerated() {
      con.inBus = i
    }
    outputConnections.first!.outBus = 0
    
    engineNode = mixer
    self.volume = node.volume
  }
}

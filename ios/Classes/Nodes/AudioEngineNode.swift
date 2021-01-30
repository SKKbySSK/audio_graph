//
//  AudioEngineNode.swift
//  audio_graph
//
//  Created by Kaisei Sunaga on 2020/01/24.
//

import Foundation
import AVFoundation

protocol AudioEngineNode: class {
  static var nodeName: String { get }
  
  var node: AudioNode { get }
  var engineNode: AVAudioNode { get }
  var inputConnections: [AudioNodeConnection] { get }
  var outputConnections: [AudioNodeConnection] { get }
  var shouldAttach: Bool { get }
  
  func dispose()
}

extension AudioEngineNode {
  func dispose() {
  }
}

protocol AudioControllableNode: class {
  func play()
  func pause()
}

protocol AudioPreparableNode: class {
  func prepare()
}

protocol AudioVolumeEditableNode: class {
  var volume: Double { get set }
}

protocol AudioPositionableNode: class {
  var position: Double { get set }
}

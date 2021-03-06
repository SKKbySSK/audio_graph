//
//  AudioEngineFilePlayerNode.swift
//  audio_graph
//
//  Created by Kaisei Sunaga on 2020/01/31.
//

import Foundation
import AVFoundation

class AudioEngineFilePlayerNode: AudioEngineNode, AudioControllableNode, AudioVolumeEditableNode, AudioPositionableNode, AudioPreparableNode {
  static let nodeName = "audio_file_player_node"
  
  private var isPrepared = false
  private var isPlaying = false
  private var ignoreCompletion = false
  private var lastPosition: Double = 0
  private var offset: Double = 0
  var node: AudioNode
  var engineNode: AVAudioNode {
    return playerNode
  }
  
  var position: Double {
    get {
      guard isPlaying else { return lastPosition }
      guard let lastTime = playerNode.lastRenderTime,
            let time = playerNode.playerTime(forNodeTime: lastTime) else { return lastPosition }
      return offset + (Double(time.sampleTime) / time.sampleRate)
    }
    set {
      guard let media = currentMedia else {
        lastPosition = newValue
        return
      }
      
      offset = newValue
      lastPosition = newValue
      
      ignoreCompletion = true
      playerNode.stop()
      let startSample = max(Int64(floor(newValue * media.file.processingFormat.sampleRate)), 0)
      let frameCount = max(UInt32(media.file.length - startSample), 0)
      
      guard frameCount != 0 else {
        ignoreCompletion = false
        return
      }
      playerNode.scheduleSegment(media.file, startingFrame: startSample, frameCount: frameCount, at: nil, completionHandler: completionHandler)
      ignoreCompletion = false
      
      if isPlaying {
        playerNode.play()
      } else {
        playerNode.pause()
      }
    }
  }
  
  let methodChannel: FlutterMethodChannel
  let inputConnections: [AudioNodeConnection]
  let outputConnections: [AudioNodeConnection]
  let shouldAttach: Bool = true
  
  var volume: Double {
    didSet {
      node.volume = volume
      playerNode.volume = Float(volume)
    }
  }
  
  private let playerNode: AVAudioPlayerNode
  private var currentMedia: (urL: URL, file: AVAudioFile)?
  
  init(_ node: AudioNode, _ channel: FlutterMethodChannel, inputConnections: [AudioNodeConnection], outputConnections: [AudioNodeConnection]) throws {
    self.methodChannel = channel
    guard node.name == AudioEngineFilePlayerNode.nodeName else { throw NSError() }
    self.node = node
    self.inputConnections = inputConnections
    self.outputConnections = outputConnections
    
    outputConnections.first!.outBus = 0
    
    let player = AVAudioPlayerNode()
    playerNode = player
    self.volume = node.volume
  }
  
  private func completionHandler() {
    guard !ignoreCompletion else {
      return
    }
    lastPosition = position
    playerNode.pause()
    methodChannel.invokeMethod("completed", arguments: node.id)
  }
  
  func prepare() {
    let url = URL(fileURLWithPath: node.parameters["path"]!)
    
    let file = try! AVAudioFile(forReading: url)
    currentMedia = (url, file)
    position = lastPosition // This will reschedule automatically
    isPrepared = true
  }
  
  func play() {
    if !isPrepared {
      prepare()
    }
    
    playerNode.play(at: nil)
    isPlaying = true
  }
  
  func pause() {
    lastPosition = position
    playerNode.pause()
    isPlaying = false
  }
  
  func dispose() {
    playerNode.stop()
  }
}

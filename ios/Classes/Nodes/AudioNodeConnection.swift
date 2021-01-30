//
//  AudioNodeConnection.swift
//  audio_graph
//
//  Created by Kaisei Sunaga on 2020/01/31.
//

import Foundation
import AVFoundation

class AudioNodeConnection {
  init(outPin: Int, inPin: Int) {
    self.outPin = outPin
    self.inPin = inPin
  }
  
  let outPin: Int
  let inPin: Int
  var outBus: AVAudioNodeBus?
  var inBus: AVAudioNodeBus?
}

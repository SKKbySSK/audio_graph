//
//  AudioEngineNode.swift
//  audio_graph
//
//  Created by Kaisei Sunaga on 2020/01/24.
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

protocol AudioEngineNode: class {
    static var nodeName: String { get }
    
    var node: AudioNode { get }
    var engineNode: AVAudioNode { get }
    var inputConnections: [AudioNodeConnection] { get }
    var outputConnections: [AudioNodeConnection] { get }
    var shouldAttach: Bool { get }
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

class AudioEngineFileNode: AudioEngineNode, AudioControllableNode, AudioVolumeEditableNode, AudioPositionableNode, AudioPreparableNode {
    static let nodeName = "audio_file_node"
    
    private var isPrepared = false
    private var isPlaying = false
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
            guard let playing = playing else {
                lastPosition = newValue
                return
            }
            
            offset = newValue
            lastPosition = newValue
            
            playerNode.stop()
            let startSample = max(Int64(floor(newValue * playing.file.processingFormat.sampleRate)), 0)
            let frameCount = max(UInt32(playing.file.length - startSample), 0)
            
            guard frameCount != 0 else { return }
            playerNode.scheduleSegment(playing.file, startingFrame: startSample, frameCount: frameCount, at: nil, completionHandler: completionHandler)
            
            if isPlaying {
                playerNode.play()
            } else {
                playerNode.pause()
            }
        }
    }
    
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
    private var playing: (urL: URL, file: AVAudioFile)?
    
    init(_ node: AudioNode, inputConnections: [AudioNodeConnection], outputConnections: [AudioNodeConnection]) throws {
        guard node.name == AudioEngineFileNode.nodeName else { throw NSError() }
        self.node = node
        self.inputConnections = inputConnections
        self.outputConnections = outputConnections
        
        outputConnections.first!.outBus = 0
        
        let player = AVAudioPlayerNode()
        playerNode = player
        self.volume = node.volume
    }
    
    private func completionHandler() {
        playerNode.pause()
    }
    
    func prepare() {
        let url = URL(fileURLWithPath: node.parameters["path"]!)
        
        let file = try! AVAudioFile(forReading: url)
        playing = (url, file)
        position = 0 // This will reschedule automatically
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
}

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
        
        inputConnections.first!.inBus = 0
        engineNode = engine.outputNode
    }
}

//
//  AudioGraphManager.swift
//  audio_graph
//
//  Created by Kaisei Sunaga on 2020/01/24.
//

import Foundation
import Flutter
import AVFoundation

class AudioGraphManagerPlugin: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
    }
    
    class AudioGraph {
        init(engine: AVAudioEngine, nodes: [AudioEngineNode]) {
            self.engine = engine
            self.nodes = nodes
        }
        
        let engine: AVAudioEngine
        let nodes: [AudioEngineNode]
    }
    
    static let id = IdManager(key: "GraphManager")
    
    static var graphs: [Int: AudioGraphManagerPlugin.AudioGraph] = [:]
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [Any],
            let graphId = args[0] as? Int, let graph = AudioGraphManagerPlugin.graphs[graphId] else { return }
        
        switch call.method {
        case "dispose":
            for node in graph.nodes {
                AudioEngineNodePlugin.nodes.removeValue(forKey: node.node.id)
            }
            
            if AudioGraphManagerPlugin.graphs.removeValue(forKey: graphId) != nil {
                result(true)
            } else {
                result(false)
            }
        default:
            break
        }
    }
}

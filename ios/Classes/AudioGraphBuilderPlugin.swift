import Flutter
import UIKit
import AVFoundation

public class AudioGraphBuilderPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "build":
            guard let json = (call.arguments as? [String])?.first else { return }
            buildGraph(json, result: result)
        default:
            break;
        }
    }
    
    private func buildGraph(_ json: String, result: @escaping FlutterResult) {
        do {
            let graph = try JSONDecoder().decode(AudioGraph.self, from: json.data(using: .utf8)!);
            let connections: [AudioNodeConnection] = graph.connections.map({ AudioNodeConnection(outPin: Int($0)!, inPin: $1) })
            
            var nodes: [AudioEngineNode] = []
            
            let engine = AVAudioEngine()
            
            for node in graph.nodes {
                var ins: [AudioNodeConnection] = []
                var outs: [AudioNodeConnection] = []
                for input in node.inputs {
                    ins.append(contentsOf: connections.filter({ $0.inPin == input.id }))
                }
                for output in node.outputs {
                    outs.append(contentsOf: connections.filter({ $0.outPin == output.id }))
                }
                
                nodes.append(try createEngineNode(node, engine: engine, inputConnections: ins, outputConnections: outs)!)
            }
            
            for node in nodes.filter({ $0.shouldAttach }) {
                engine.attach(node.engineNode)
            }
            
            for node in nodes {
                for connection in node.outputConnections {
                    let to = connectedNode(of: connection.inPin, nodes: nodes)!
                    engine.connect(node.engineNode, to: to.engineNode, fromBus: connection.outBus!, toBus: connection.inBus!, format: nil)
                }
            }
            
            try engine.start()
            
            for node in nodes {
                AudioEngineNodePlugin.nodes[node.node.id] = node
            }
            
            let id = AudioGraphManagerPlugin.id.generateId()
            AudioGraphManagerPlugin.graphs[id] = AudioGraphManagerPlugin.AudioGraph(engine: engine, nodes: nodes)
            result(id)
        } catch let error {
            print(error)
        }
    }
    
    private func createEngineNode(_ node: AudioNode, engine: AVAudioEngine, inputConnections: [AudioNodeConnection], outputConnections: [AudioNodeConnection]) throws -> AudioEngineNode? {
        switch node.name {
        case AudioEngineFileNode.nodeName:
            return try AudioEngineFileNode(node, inputConnections: inputConnections, outputConnections: outputConnections)
        case AudioEngineMixerNode.nodeName:
            return try AudioEngineMixerNode(node, inputConnections: inputConnections, outputConnections: outputConnections)
        case AudioEngineDeviceOutputNode.nodeName:
            return try AudioEngineDeviceOutputNode(node, engine: engine, inputConnections: inputConnections, outputConnections: outputConnections)
        default:
            return nil
        }
    }
    
    private func connectedNode(of pinId: Int, nodes: [AudioEngineNode]) -> AudioEngineNode? {
        for node in nodes {
            for input in node.node.inputs {
                if pinId == input.id {
                    return node
                }
            }
        }
        
        return nil;
    }
}

//
//  Registrar.swift
//  audio_graph
//
//  Created by Kaisei Sunaga on 2020/01/24.
//

import Foundation
import Flutter

public class PluginRegistrar: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let domain = "audio_graph"
    
    let graphBuilder = FlutterMethodChannel(name: "\(domain)/graph_builder", binaryMessenger: registrar.messenger())
    let graphBuilderInstance = AudioGraphBuilderPlugin()
    registrar.addMethodCallDelegate(graphBuilderInstance, channel: graphBuilder)
    
    let fileChannel = FlutterMethodChannel(name: "\(domain)/file", binaryMessenger: registrar.messenger())
    let fileInstance = AudioFileNodePlugin()
    registrar.addMethodCallDelegate(fileInstance, channel: fileChannel)
    
    let graphChannel = FlutterMethodChannel(name: "\(domain)/graph", binaryMessenger: registrar.messenger())
    let graphInstance = AudioGraphManagerPlugin()
    registrar.addMethodCallDelegate(graphInstance, channel: graphChannel)
    
    let nodeChannel = FlutterMethodChannel(name: "\(domain)/node", binaryMessenger: registrar.messenger())
    let nodeInstance = AudioEngineNodePlugin()
    registrar.addMethodCallDelegate(nodeInstance, channel: nodeChannel)
  }
}

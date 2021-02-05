//
//  PluginError.swift
//  audio_graph
//
//  Created by Kaisei Sunaga on 2021/02/05.
//

import Foundation
import Flutter

class PluginError {
  static func createInvalidOperation(message: String?, details: Any? = nil) -> FlutterError {
    return FlutterError(code: "ERR_INVALID_OPERATION", message: message, details: details)
  }
  
  static func createNodeNotFound(message: String? = nil, details: Any? = nil) -> FlutterError {
    return FlutterError(code: "ERR_NODE_NOTFOUND", message: message ?? "The specified node was not found or already disposed", details: details)
  }
  
  static func createGraphBuildFailed(message: String? = nil, details: Any? = nil) -> FlutterError {
    return FlutterError(code: "ERR_GRAPH_BUILD_FAILED", message: message ?? "Failed to build audio graph", details: details)
  }
}

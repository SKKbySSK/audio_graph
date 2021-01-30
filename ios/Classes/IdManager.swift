//
//  IdManager.swift
//  audio_graph
//
//  Created by Kaisei Sunaga on 2020/01/24.
//

import Foundation

class IdManager {
  private static var ids: [String: Int] = [:]
  
  static func generateId(for key: String) -> Int {
    if let value = ids[key] {
      ids[key] = value + 1
      return value + 1
    } else {
      ids[key] = 0
      return 0
    }
  }
  
  private let key: String
  
  init(key: String) {
    self.key = key
  }
  
  func generateId() -> Int {
    return IdManager.generateId(for: key)
  }
}

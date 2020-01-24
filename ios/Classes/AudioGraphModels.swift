import Foundation

// MARK: - Graph
struct AudioGraph: Codable {
    let connections: [String: Int]
    let nodes: [AudioNode]
}

// MARK: - Node
struct AudioNode: Codable, Equatable {
    let id: Int
    let name: String
    var volume: Double
    let inputs, outputs: [AudioPin]
    let parameters: [String: String]
}

// MARK: - Pin
struct AudioPin: Codable, Equatable {
    let id: Int
    let format: AudioFormat
}

// MARK: - AudioFormat
struct AudioFormat: Codable, Equatable {
    let sampleRate, channels: Int

    enum CodingKeys: String, CodingKey {
        case sampleRate = "sample_rate"
        case channels
    }
}

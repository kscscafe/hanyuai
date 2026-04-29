//
//  HSKLevel.swift
//  hanyuai
//

import Foundation

enum HSKLevel: Int, CaseIterable, Identifiable, Hashable {
    case hsk1 = 1
    case hsk2 = 2
    case hsk3 = 3
    case hsk4 = 4

    var id: Int { rawValue }
    var label: String { "HSK\(rawValue)" }
}

// JSON では "HSK1" のような文字列、独自エンコード時は Int を期待する両方に対応する。
extension HSKLevel: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            switch str.uppercased() {
            case "HSK1": self = .hsk1
            case "HSK2": self = .hsk2
            case "HSK3": self = .hsk3
            case "HSK4": self = .hsk4
            default:
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unknown HSK level string: \(str)"
                )
            }
            return
        }
        let raw = try container.decode(Int.self)
        guard let level = HSKLevel(rawValue: raw) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid HSK level raw value: \(raw)"
            )
        }
        self = level
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

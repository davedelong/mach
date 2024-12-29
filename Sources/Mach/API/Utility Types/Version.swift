//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public struct Version: CustomStringConvertible {
    
    public let pieces: Array<Int>
    
    public var description: String { pieces.map(\.description).joined(separator: ".") }
    
    internal init(rawValue: UInt32) {
        /* X.Y.Z is encoded in nibbles xxxx.yy.zz */
        self.pieces = [
            Int((rawValue >> 16) & 0xFFFF),
            Int((rawValue >> 8) & 0xFF),
            Int(rawValue & 0xFF)
        ]
    }
    
    internal init(rawValue: UInt64) {
        /* A.B.C.D.E packed as a24.b10.c10.d10.e10 */
        self.pieces = [
            Int((rawValue >> 40) & 0xFFFFFF),
            Int((rawValue >> 30) & 0x3FF),
            Int((rawValue >> 20) & 0x3FF),
            Int((rawValue >> 10) & 0x3FF),
            Int(rawValue & 0x3FF)
        ]
    }
    
}

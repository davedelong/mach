//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

extension String {
    
    internal init?(cString: UnsafePointer<CChar>, maxLength: Int) {
        var characters = Array<CChar>()
        let buffer = UnsafeBufferPointer(start: cString, count: maxLength)
        for character in buffer {
            if character == 0 { break }
            characters.append(character)
        }
        characters.append(0)
        self.init(utf8String: characters)
    }
    
}

extension String.StringInterpolation {
    
    internal mutating func appendInterpolation<Value>(describing value: Value?) {
        self.appendInterpolation(String(describing: value))
    }
    
    internal mutating func appendInterpolation<Value: BinaryInteger>(hex value: Value) {
        self.appendInterpolation("0x" + String(value, radix: 16, uppercase: true))
    }
}

extension RangeReplaceableCollection {
        
    internal init(pointer: UnsafeRawPointer, count: Int) {
        let bytes = pointer.assumingMemoryBound(to: Element.self)
        let buffer = UnsafeBufferPointer(start: bytes, count: count)
        self.init()
        self.append(contentsOf: buffer)
    }
    
}

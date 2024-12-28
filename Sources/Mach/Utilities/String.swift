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
    
    internal init?(nextString startingFrom: inout Pointer<UInt8>, limitedBy end: Pointer<UInt8>) {
        var ptr = startingFrom
        var extracted: String? = nil
        
        while extracted == nil {
            // consume all leading null bytes:
            while ptr.dereference == 0 && ptr < end {
                ptr = ptr.advanced(by: 1)
            }
            if ptr >= end { break }
            
            // find all non-null bytes
            let stringStart = ptr
            while ptr.dereference != 0 && ptr < end {
                ptr = ptr.advanced(by: 1)
            }
            
            if ptr >= end { break }
            
            // make sure we're pointing at a null byte
            guard ptr.dereference == 0 else { break }
            
            let count = stringStart.distance(to: ptr)
            
            extracted = stringStart.withTypedPointer(perform: { pointer in
                let buffer = UnsafeBufferPointer(start: pointer, count: count)
                return String(bytes: buffer, encoding: .utf8)
            })
        }
        
        guard let extracted else { return nil }
        
        // when we exit the loop and have a string, ptr is pointing to the last null byte in the string
        // advanced it to the next byte, to indicate the apparent start of the next string
        startingFrom = ptr.advanced(by: 1)
        
        self = extracted
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

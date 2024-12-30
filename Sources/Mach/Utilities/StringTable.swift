//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/29/24.
//

import Foundation

internal struct StringTable: Sequence {
    private let start: Pointer<UInt8>
    private let end: Pointer<UInt8>
    
    init(start: Pointer<UInt8>, size: Int) {
        self.start = start
        self.end = start.advanced(by: size)
    }
    
    func readString(onOrAfter offset: Int) -> String? {
        var approximateStart = start.advanced(by: offset)
        return String(nextString: &approximateStart, limitedBy: end)
    }
    
    func makeIterator() -> AnyIterator<String> {
        var current = start
        return AnyIterator { String(nextString: &current, limitedBy: end) }
    }
    
}

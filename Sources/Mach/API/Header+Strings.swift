//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/27/24.
//

import Foundation

extension Header {
    
    public var allSections: Array<Section> {
        let segments = self.commands.compactMap { $0 as? SegmentCommand }
        return segments.flatMap(\.sections)
    }
    
    public var codeSignature: CodeSignatureCommand? {
        return self.commands.lazy.compactMap { $0 as? CodeSignatureCommand }.first
    }
    
    public var entitlements: Dictionary<String, Any>? {
        if let entitlements = codeSignature?.entitlements { return entitlements }
        
        // try reading it from __TEXT
        guard let section = allSections.first(where: { $0.name == "__TEXT.__entitlements" }) else {
            return nil
        }
        
        let pointer = section.dataPointer
        let size = section.dataSize
        let data = pointer.copyBytes(maxLength: size)
        
        let obj = try? PropertyListSerialization.propertyList(from: data, format: nil)
        return obj as? Dictionary<String, Any>
    }
    
    public var strings: any Sequence<String> {
        return allSections
            .filter {
                $0.sectionType == .cStringLiterals || $0.name == "__TEXT.__swift5reflstr"
            }
            .flatMap { section in
                let size = section.dataSize
                let pointer = section.dataPointer
                let end = pointer.advanced(by: Int(size))
                
                let charPointer = pointer.rebound(to: UInt8.self)
                
                return sequence(state: charPointer, next: { ptr -> String? in
                    while ptr.dereference == 0 && ptr < end {
                        ptr = ptr.advanced(by: 1)
                    }
                    if ptr >= end { return nil }
                    
                    let startOfString = ptr
                    var endOfString = ptr.advanced(by: 1)
                    
                    while endOfString.dereference != 0 && endOfString < end {
                        endOfString = endOfString.advanced(by: 1)
                    }
                    
                    if endOfString >= end { return nil }
                    // endOfString now points to the end of the string
                    
                    ptr = endOfString.advanced(by: 1)
                    return startOfString.withTypedPointer(perform: { String(cString: $0) })
                })
            }
    }
    
}

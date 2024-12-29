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
        return segments.flatMap { discretify($0.sections) }
    }
    
    public var codeSignature: CodeSignatureCommand? {
        return self.commands.compactMap { $0 as? CodeSignatureCommand }.first
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
        return commands.flatMap { discretify($0.strings) }
    }
    
}


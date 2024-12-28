//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

/*
 LC_DATA_IN_CODE
 LC_DYLD_CHAINED_FIXUPS
 LC_DYLD_EXPORTS_TRIE
 LC_DYSYMTAB
 LC_FUNCTION_STARTS
 LC_SEGMENT_SPLIT_INFO 
 */

public struct AnyCommand: Command {
    public typealias RawValue = load_command
    
    public var header: Header
    
    public var commandPointer: Pointer<load_command>
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
    public init?(_ other: any Command) {
        self.header = other.header
        self.commandPointer = other.commandPointer
    }
    
}

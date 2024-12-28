//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/27/24.
//

import Foundation

public struct SymbolTableCommand: Command {
    
    public typealias RawValue = symtab_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
//    public var symoff: UInt32 /* symbol table offset */
//
//    public var nsyms: UInt32 /* number of symbol table entries */
//
//    public var stroff: UInt32 /* string table offset */
//
//    public var strsize: UInt32 /* string table size in bytes */
    
}

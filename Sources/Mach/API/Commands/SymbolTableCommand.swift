//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/27/24.
//

import Foundation

#warning("This is incomplete")

public struct SymbolTableCommand: Command {
    
    public typealias RawValue = symtab_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var strings: any Sequence<String> {
        discretify(symbols).lazy.map(\.string)
    }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
    public var symbols: any Collection<Symbol> {
        let is64Bit = header.is64Bit
        
        let symbolCount = pointer.nsyms.swapping(needsSwapping)
        let symbolTableOffset = pointer.symoff.swapping(needsSwapping)
        let symbolTablePointer = header.pointer(of: UInt8.self, at: symbolTableOffset)
        
        let stringSize = pointer.strsize.swapping(needsSwapping)
        let stringOffset = pointer.stroff.swapping(needsSwapping)
        let stringPointer = header.pointer(of: UInt8.self, at: stringOffset)
        let stringPointerEnd = stringPointer.advanced(by: stringSize)
        
        return collection(count: symbolCount, state: symbolTablePointer, next: { symbolPointer in
            let symbol: Symbol
            if is64Bit {
                symbol = Symbol(header: header, pointer: symbolPointer.rebound(to: nlist_64.self), stringTable: stringPointer, stringTableEnd: stringPointerEnd)
                symbolPointer = symbolPointer.advanced(by: MemoryLayout<nlist_64>.size)
            } else {
                symbol = Symbol(header: header, pointer: symbolPointer.rebound(to: nlist.self), stringTable: stringPointer, stringTableEnd: stringPointerEnd)
                symbolPointer = symbolPointer.advanced(by: MemoryLayout<nlist>.size)
            }
            
            return symbol
        })
    }
    
}

public struct Symbol {
    
    public let string: String
    
    init(header: Header, pointer: Pointer<nlist_64>, stringTable: Pointer<UInt8>, stringTableEnd: Pointer<UInt8>) {
        let stringOffset = pointer.n_un.n_strx.swapping(header.needsSwapping)
        if stringOffset == 0 {
            self.string = ""
        } else {
            var strStart = stringTable.advanced(by: stringOffset)
            self.string = String(nextString: &strStart, limitedBy: stringTableEnd)!
        }
    }
    
    init(header: Header, pointer: Pointer<nlist>, stringTable: Pointer<UInt8>, stringTableEnd: Pointer<UInt8>) {
        let stringOffset = pointer.n_un.n_strx.swapping(header.needsSwapping)
        if stringOffset == 0 {
            self.string = ""
        } else {
            var strStart = stringTable.advanced(by: stringOffset)
            self.string = String(nextString: &strStart, limitedBy: stringTableEnd)!
        }
    }
    
}

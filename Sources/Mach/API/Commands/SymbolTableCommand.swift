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
        discretify(symbols).lazy.map(\.name)
    }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
    public var symbols: any Collection<Symbol> {
        
        let symbolCount = pointer.nsyms.swapping(needsSwapping)
        let symbolTableOffset = pointer.symoff.swapping(needsSwapping)
        let symbolTablePointer = header.pointer(of: nlist.self, at: symbolTableOffset)
        let symbolSize = header.is64Bit ? MemoryLayout<nlist_64>.size : MemoryLayout<nlist>.size
        
        let stringSize = pointer.strsize.swapping(needsSwapping)
        let stringOffset = pointer.stroff.swapping(needsSwapping)
        let stringPointer = header.pointer(of: UInt8.self, at: stringOffset)
        let strings = StringTable(start: stringPointer, size: Int(stringSize))
        
        return collection(count: symbolCount, state: symbolTablePointer, next: { symbolPointer in
            let symbol = Symbol(header: header, pointer: symbolPointer, stringTable: strings)
            symbolPointer = symbolPointer.advanced(by: symbolSize)
            return symbol
        })
    }
    
}

public struct Symbol {
    
    public enum SymbolType {
        case undefined
        case absolute
        case definedInSection
        case definedInDylib
        case indirect
    }
    
    private let header: Header
    private let pointer: Pointer<nlist>
    
    public let name: String
    
    public var isSymbolicDebuggingEntry: Bool { (Int32(rawType) & N_STAB) != 0 }
    public var isPrivateExternalSymbol: Bool { (Int32(rawType) & N_PEXT) == N_PEXT }
    public var isExternalSymbol: Bool { (Int32(rawType) & N_EXT) == N_EXT }
    
    public var symbolType: SymbolType {
        let typeBits = Int32(rawType) & N_TYPE
        switch typeBits {
            case N_ABS: return .absolute
            case N_SECT: return .definedInSection
            case N_PBUD: return .definedInDylib
            case N_INDR: return .indirect
            default: return .undefined
        }
    }
    
    private  var rawType: UInt8 { pointer.n_type.swapping(header.needsSwapping) }
    private var rawSect: UInt8 { pointer.n_sect.swapping(header.needsSwapping) }
    private var rawDesc: UInt16 { UInt16(pointer.n_desc.swapping(header.needsSwapping)) }
    private var rawValue: UInt64 {
        if header.is64Bit {
            return pointer.rebound(to: nlist_64.self).n_value.swapping(header.needsSwapping)
        } else {
            return UInt64(pointer.n_value.swapping(header.needsSwapping))
        }
    }
    
    init(header: Header, pointer: Pointer<nlist>, stringTable: StringTable) {
        self.header = header
        self.pointer = pointer
        
        // both nlist and nlist_64 have a UInt32 at the same offset for the string index
        let stringOffset = Int(pointer.n_un.n_strx.swapping(header.needsSwapping))
        
        if stringOffset == 0 {
            self.name = ""
        } else {
            self.name = stringTable.readString(onOrAfter: stringOffset)!
        }
        
        /*
         * The n_type field really contains four fields:
         *    unsigned char N_STAB:3,
         *              N_PEXT:1,
         *              N_TYPE:3,
         *              N_EXT:1;
         * which are used via the following masks.
         #define    N_STAB    0xe0  /* if any of these bits set, a symbolic debugging entry */
         #define    N_PEXT    0x10  /* private external symbol bit */
         #define    N_TYPE    0x0e  /* mask for the type bits */
         #define    N_EXT    0x01  /* external symbol bit, set for external symbols */
         */
        
    }
    
}

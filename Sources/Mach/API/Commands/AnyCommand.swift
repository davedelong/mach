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

private let cmdLock = NSLock()
private var cmdTypes: Array<any Command.Type> = [
    SegmentCommand.self,
    UUIDCommand.self,
    RPathCommand.self,
    DylibCommand.self,
    BuildVersionCommand.self,
    SourceVersionCommand.self,
    CodeSignatureCommand.self,
    SymbolTableCommand.self,
    DylinkerCommand.self,
    MainCommand.self,
    SubClientCommand.self,
    SubFrameworkCommand.self,
    SubLibraryCommand.self,
    SubUmbrellaCommand.self,
    DyldInfoCommand.self
]

public func registerCommand(_ type: any Command.Type) {
    cmdLock.lock()
    cmdTypes.append(type)
    cmdLock.unlock()
}

internal func command(for cmd: UInt32) -> any Command.Type {
    let type = cmdLock.withLock {
        cmdTypes.last(where: { $0.matches(cmd) })
    }
    return type ?? AnyCommand.self
}

public struct AnyCommand: Command {
    public typealias RawValue = load_command
    public static func matches(_ cmd: UInt32) -> Bool { true }
    
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

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

private let commandTypes: Dictionary<UInt32, any Command.Type> = [
//    LC_REQ_DYLD: "LC_REQ_DYLD",
    UInt32(bitPattern: LC_SEGMENT): SegmentCommand.self,
    UInt32(bitPattern: LC_SYMTAB): SymbolTableCommand.self,
//    UInt32(bitPattern: LC_SYMSEG): "LC_SYMSEG",
//    UInt32(bitPattern: LC_THREAD): "LC_THREAD",
//    UInt32(bitPattern: LC_UNIXTHREAD): "LC_UNIXTHREAD",
//    UInt32(bitPattern: LC_LOADFVMLIB): "LC_LOADFVMLIB",
//    UInt32(bitPattern: LC_IDFVMLIB): "LC_IDFVMLIB",
//    UInt32(bitPattern: LC_IDENT): "LC_IDENT",
//    UInt32(bitPattern: LC_FVMFILE): "LC_FVMFILE",
//    UInt32(bitPattern: LC_PREPAGE): "LC_PREPAGE",
//    UInt32(bitPattern: LC_DYSYMTAB): "LC_DYSYMTAB",
    UInt32(bitPattern: LC_LOAD_DYLIB): DylibCommand.self,
    UInt32(bitPattern: LC_ID_DYLIB): DylibCommand.self,
    UInt32(bitPattern: LC_LOAD_DYLINKER): DylinkerCommand.self,
    UInt32(bitPattern: LC_ID_DYLINKER): DylinkerCommand.self,
//    UInt32(bitPattern: LC_PREBOUND_DYLIB): "LC_PREBOUND_DYLIB",
//    UInt32(bitPattern: LC_ROUTINES): "LC_ROUTINES",
    UInt32(bitPattern: LC_SUB_FRAMEWORK): SubFrameworkCommand.self,
    UInt32(bitPattern: LC_SUB_UMBRELLA): SubUmbrellaCommand.self,
    UInt32(bitPattern: LC_SUB_CLIENT): SubClientCommand.self,
    UInt32(bitPattern: LC_SUB_LIBRARY): SubLibraryCommand.self,
//    UInt32(bitPattern: LC_TWOLEVEL_HINTS): "LC_TWOLEVEL_HINTS",
//    UInt32(bitPattern: LC_PREBIND_CKSUM): "LC_PREBIND_CKSUM",
    LC_LOAD_WEAK_DYLIB: DylibCommand.self,
    UInt32(bitPattern: LC_SEGMENT_64): SegmentCommand.self,
//    UInt32(bitPattern: LC_ROUTINES_64): "LC_ROUTINES_64",
    UInt32(bitPattern: LC_UUID): UUIDCommand.self,
    LC_RPATH: RPathCommand.self,
    UInt32(bitPattern: LC_CODE_SIGNATURE): CodeSignatureCommand.self,
//    UInt32(bitPattern: LC_SEGMENT_SPLIT_INFO): "LC_SEGMENT_SPLIT_INFO",
    LC_REEXPORT_DYLIB: DylibCommand.self,
//    UInt32(bitPattern: LC_LAZY_LOAD_DYLIB): "LC_LAZY_LOAD_DYLIB",
//    UInt32(bitPattern: LC_ENCRYPTION_INFO): "LC_ENCRYPTION_INFO",
    UInt32(bitPattern: LC_DYLD_INFO): DyldInfoCommand.self,
    LC_DYLD_INFO_ONLY: DyldInfoCommand.self,
    LC_LOAD_UPWARD_DYLIB: DylibCommand.self,
//    UInt32(bitPattern: LC_VERSION_MIN_MACOSX): "LC_VERSION_MIN_MACOSX",
//    UInt32(bitPattern: LC_VERSION_MIN_IPHONEOS): "LC_VERSION_MIN_IPHONEOS",
//    UInt32(bitPattern: LC_FUNCTION_STARTS): "LC_FUNCTION_STARTS",
    UInt32(bitPattern: LC_DYLD_ENVIRONMENT): DylinkerCommand.self,
    LC_MAIN: MainCommand.self,
//    UInt32(bitPattern: LC_DATA_IN_CODE): "LC_DATA_IN_CODE",
    UInt32(bitPattern: LC_SOURCE_VERSION): SourceVersionCommand.self,
//    UInt32(bitPattern: LC_DYLIB_CODE_SIGN_DRS): "LC_DYLIB_CODE_SIGN_DRS",
//    UInt32(bitPattern: LC_ENCRYPTION_INFO_64): "LC_ENCRYPTION_INFO_64",
//    UInt32(bitPattern: LC_LINKER_OPTION): "LC_LINKER_OPTION",
//    UInt32(bitPattern: LC_LINKER_OPTIMIZATION_HINT): "LC_LINKER_OPTIMIZATION_HINT",
//    UInt32(bitPattern: LC_VERSION_MIN_TVOS): "LC_VERSION_MIN_TVOS",
//    UInt32(bitPattern: LC_VERSION_MIN_WATCHOS): "LC_VERSION_MIN_WATCHOS",
//    UInt32(bitPattern: LC_NOTE): "LC_NOTE",
    UInt32(bitPattern: LC_BUILD_VERSION): BuildVersionCommand.self,
//    LC_DYLD_EXPORTS_TRIE: "LC_DYLD_EXPORTS_TRIE",
//    LC_DYLD_CHAINED_FIXUPS: "LC_DYLD_CHAINED_FIXUPS",
//    LC_FILESET_ENTRY: "LC_FILESET_ENTRY",
//    UInt32(bitPattern: LC_ATOM_INFO): "LC_ATOM_INFO"
]

internal func command(for cmd: UInt32) -> any Command.Type {
    return commandTypes[cmd] ?? AnyCommand.self
}

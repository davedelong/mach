//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public protocol Command: MachObject {
    var header: Header { get }
    var commandPointer: Pointer<load_command> { get }
    var strings: any Sequence<String> { get }
    
    init(header: Header, commandPointer: Pointer<load_command>)
    
    init?(_ other: any Command)
}

extension Command {
    
    public var pointer: Pointer<RawValue> { commandPointer.rebound() }
    
    public var strings: any Sequence<String> { [] }
    
    public var commandType: CommandType {
        let rawValue = commandPointer.cmd.swapping(needsSwapping)
        return CommandType(rawValue: rawValue)
    }
    
    public var commandSize: Int {
        let rawValue = commandPointer.cmdsize.swapping(needsSwapping)
        return Int(rawValue)
    }
    
    public var commandName: String { commandType.name }
    
    public var defaultDescription: String { "\(commandName) @ \(pointer)" }
    public var description: String { defaultDescription }
    
    public init?(_ other: any Command) {
        let rawCmd = other.commandType.rawValue
        let expectedType = command(for: rawCmd)
        if Self.self == AnyCommand.self || Self.self == expectedType {
            self.init(header: other.header, commandPointer: other.commandPointer)
        } else {
            return nil
        }
    }
    
}
    
public struct CommandType: RawRepresentable {
    public static let segment = CommandType(rawValue: UInt32(LC_SEGMENT))
    public static let segment64 = CommandType(rawValue: UInt32(LC_SEGMENT_64))
    public static let uuid = CommandType(rawValue: UInt32(LC_UUID))
    public static let codeSignature = CommandType(rawValue: UInt32(LC_CODE_SIGNATURE))
    public static let loadDylib = CommandType(rawValue: UInt32(LC_LOAD_DYLIB))
    public static let loadWeakDylib = CommandType(rawValue: LC_LOAD_WEAK_DYLIB)
    public static let rpath = CommandType(rawValue: LC_RPATH)
    
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public var name: String {
        return commandNames[rawValue] ?? "Unknown Command: \(hex: rawValue)"
    }
}

extension Command {
    
    internal var is64Bit: Bool { header.is64Bit }
    internal var needsSwapping: Bool { header.needsSwapping }
    
    internal func readLCString(_ keyPath: KeyPath<RawValue, lc_str>) -> String {
        let size = self.commandSize
        
        let (offset, length) =  self.pointer.withTypedPointer { base -> (Int, Int) in
            let offset = Int(base.pointee[keyPath: keyPath].offset.swapping(needsSwapping))
            let length = size - offset
            return (offset, length)
        }
        
        let str = self.pointer.withUntypedPointer(perform: { base -> String? in
            let strStart = base.advanced(by: offset).assumingMemoryBound(to: CChar.self)
            return String(cString: strStart, maxLength: length)
        })
        
        return str ?? ""
    }
}

private let commandTypes: Dictionary<UInt32, any Command.Type> = [
//    LC_REQ_DYLD: "LC_REQ_DYLD",
    UInt32(LC_SEGMENT): SegmentCommand.self,
    UInt32(LC_SYMTAB): SymbolTableCommand.self,
//    UInt32(LC_SYMSEG): "LC_SYMSEG",
//    UInt32(LC_THREAD): "LC_THREAD",
//    UInt32(LC_UNIXTHREAD): "LC_UNIXTHREAD",
//    UInt32(LC_LOADFVMLIB): "LC_LOADFVMLIB",
//    UInt32(LC_IDFVMLIB): "LC_IDFVMLIB",
//    UInt32(LC_IDENT): "LC_IDENT",
//    UInt32(LC_FVMFILE): "LC_FVMFILE",
//    UInt32(LC_PREPAGE): "LC_PREPAGE",
//    UInt32(LC_DYSYMTAB): "LC_DYSYMTAB",
    UInt32(LC_LOAD_DYLIB): DylibCommand.self,
    UInt32(LC_ID_DYLIB): DylibCommand.self,
    UInt32(LC_LOAD_DYLINKER): DylinkerCommand.self,
    UInt32(LC_ID_DYLINKER): DylinkerCommand.self,
//    UInt32(LC_PREBOUND_DYLIB): "LC_PREBOUND_DYLIB",
//    UInt32(LC_ROUTINES): "LC_ROUTINES",
    UInt32(LC_SUB_FRAMEWORK): SubFrameworkCommand.self,
    UInt32(LC_SUB_UMBRELLA): SubUmbrellaCommand.self,
    UInt32(LC_SUB_CLIENT): SubClientCommand.self,
    UInt32(LC_SUB_LIBRARY): SubLibraryCommand.self,
//    UInt32(LC_TWOLEVEL_HINTS): "LC_TWOLEVEL_HINTS",
//    UInt32(LC_PREBIND_CKSUM): "LC_PREBIND_CKSUM",
    LC_LOAD_WEAK_DYLIB: DylibCommand.self,
    UInt32(LC_SEGMENT_64): SegmentCommand.self,
//    UInt32(LC_ROUTINES_64): "LC_ROUTINES_64",
    UInt32(LC_UUID): UUIDCommand.self,
    LC_RPATH: RPathCommand.self,
    UInt32(LC_CODE_SIGNATURE): CodeSignatureCommand.self,
//    UInt32(LC_SEGMENT_SPLIT_INFO): "LC_SEGMENT_SPLIT_INFO",
    LC_REEXPORT_DYLIB: DylibCommand.self,
    UInt32(LC_LAZY_LOAD_DYLIB): DylibCommand.self,
//    UInt32(LC_ENCRYPTION_INFO): "LC_ENCRYPTION_INFO",
    UInt32(LC_DYLD_INFO): DyldInfoCommand.self,
    LC_DYLD_INFO_ONLY: DyldInfoCommand.self,
    LC_LOAD_UPWARD_DYLIB: DylibCommand.self,
    UInt32(LC_VERSION_MIN_MACOSX): MinimumVersionCommand.self,
    UInt32(LC_VERSION_MIN_IPHONEOS): MinimumVersionCommand.self,
//    UInt32(LC_FUNCTION_STARTS): "LC_FUNCTION_STARTS",
    UInt32(LC_DYLD_ENVIRONMENT): DylinkerCommand.self,
    LC_MAIN: MainCommand.self,
//    UInt32(LC_DATA_IN_CODE): "LC_DATA_IN_CODE",
    UInt32(LC_SOURCE_VERSION): SourceVersionCommand.self,
//    UInt32(LC_DYLIB_CODE_SIGN_DRS): "LC_DYLIB_CODE_SIGN_DRS",
//    UInt32(LC_ENCRYPTION_INFO_64): "LC_ENCRYPTION_INFO_64",
//    UInt32(LC_LINKER_OPTION): "LC_LINKER_OPTION",
//    UInt32(LC_LINKER_OPTIMIZATION_HINT): "LC_LINKER_OPTIMIZATION_HINT",
    UInt32(LC_VERSION_MIN_TVOS): MinimumVersionCommand.self,
    UInt32(LC_VERSION_MIN_WATCHOS): MinimumVersionCommand.self,
//    UInt32(LC_NOTE): "LC_NOTE",
    UInt32(LC_BUILD_VERSION): BuildVersionCommand.self,
//    LC_DYLD_EXPORTS_TRIE: "LC_DYLD_EXPORTS_TRIE",
//    LC_DYLD_CHAINED_FIXUPS: "LC_DYLD_CHAINED_FIXUPS",
//    LC_FILESET_ENTRY: "LC_FILESET_ENTRY",
//    UInt32(LC_ATOM_INFO): "LC_ATOM_INFO"
]

internal func command(for cmd: UInt32) -> any Command.Type {
    return commandTypes[cmd] ?? AnyCommand.self
}

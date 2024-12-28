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



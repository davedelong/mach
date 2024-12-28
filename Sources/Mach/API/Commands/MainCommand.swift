//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/27/24.
//

import Foundation

public struct MainCommand: Command {
    
    public typealias RawValue = entry_point_command
    
    public static func matches(_ cmd: UInt32) -> Bool { cmd == LC_MAIN }
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var entryOffset: UInt64 { pointer.entryoff.swapping(needsSwapping) }
    
    public var stackSize: UInt64 { pointer.stacksize.swapping(needsSwapping) }
    
    public var description: String { "\(defaultDescription) - entry @ offset \(entryOffset) (stack size: \(stackSize))" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

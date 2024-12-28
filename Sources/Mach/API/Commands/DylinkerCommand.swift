//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/27/24.
//

import Foundation

public struct DylinkerCommand: Command {
    
    public typealias RawValue = dylinker_command
    
    public static func matches(_ cmd: UInt32) -> Bool { cmd == LC_ID_DYLINKER || cmd == LC_LOAD_DYLINKER || cmd == LC_DYLD_ENVIRONMENT }
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var name: String { readLCString(\.name) }
    
    public var description: String { "\(defaultDescription) - \(name)" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

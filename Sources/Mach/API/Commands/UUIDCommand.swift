//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public struct UUIDCommand: Command {
    
    public typealias RawValue = uuid_command
    
    public static func matches(_ cmd: UInt32) -> Bool { cmd == LC_UUID }
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var uuid: UUID { UUID(uuid: pointer.uuid) }
    
    public var description: String { "\(defaultDescription) - \(uuid)" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

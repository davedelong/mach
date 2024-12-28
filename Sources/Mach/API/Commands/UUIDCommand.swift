//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public struct UUIDCommand: Command {
    
    public typealias RawValue = uuid_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var uuid: UUID { UUID(uuid: pointer.uuid) }
    
    public var strings: any Sequence<String> { [uuid.uuidString] }
    
    public var description: String { "\(defaultDescription) - \(uuid)" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

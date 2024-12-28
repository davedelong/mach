//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

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

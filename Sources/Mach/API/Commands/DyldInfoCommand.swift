//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/27/24.
//

import Foundation

#warning("This is incomplete")

public struct DyldInfoCommand: Command {
    
    public typealias RawValue = dyld_info_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

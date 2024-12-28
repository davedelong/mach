//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/27/24.
//

import Foundation

public struct DylinkerCommand: Command {
    
    public typealias RawValue = dylinker_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var name: String { readLCString(\.name) }
    
    public var strings: any Sequence<String> { [name] }
    
    public var description: String { "\(defaultDescription) - \(name)" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

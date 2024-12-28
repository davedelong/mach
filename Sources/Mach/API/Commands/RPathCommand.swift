//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public struct RPathCommand: Command {
    
    public typealias RawValue = rpath_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var path: String { readLCString(\.path) }
    
    public var strings: any Sequence<String> { [path] }
    
    public var description: String { "\(defaultDescription) - \(path)" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public struct RPathCommand: Command {
    
    public typealias RawValue = rpath_command
    
    public static func matches(_ cmd: UInt32) -> Bool { cmd == LC_RPATH }
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var path: String { readLCString(\.path) }
    
    public var description: String { "\(defaultDescription) - \(path)" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

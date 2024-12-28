//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/27/24.
//

import Foundation

public struct SubUmbrellaCommand: Command {
    
    public typealias RawValue = sub_umbrella_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var umbrella: String { readLCString(\.sub_umbrella) }
    
    public var description: String { "\(defaultDescription) - \(umbrella)" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

public struct SubFrameworkCommand: Command {
    
    public typealias RawValue = sub_framework_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var umbrella: String { readLCString(\.umbrella) }
    
    public var description: String { "\(defaultDescription) - \(umbrella)" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

public struct SubClientCommand: Command {
    
    public typealias RawValue = sub_client_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var client: String { readLCString(\.client) }
    
    public var description: String { "\(defaultDescription) - \(client)" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

public struct SubLibraryCommand: Command {
    
    public typealias RawValue = sub_library_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var library: String { readLCString(\.sub_library) }
    
    public var description: String { "\(defaultDescription) - \(library)" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

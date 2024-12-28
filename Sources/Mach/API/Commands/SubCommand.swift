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
    
    public var subUmbrella: String { readLCString(\.sub_umbrella) }
    
    public var strings: any Sequence<String> { [subUmbrella] }
    
    public var description: String { "\(defaultDescription) - \(subUmbrella)" }
    
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
    
    public var strings: any Sequence<String> { [umbrella] }
    
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
    
    public var strings: any Sequence<String> { [client] }
    
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
    
    public var subLibrary: String { readLCString(\.sub_library) }
    
    public var strings: any Sequence<String> { [subLibrary] }
    
    public var description: String { "\(defaultDescription) - \(subLibrary)" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

//
//  File.swift
//
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public struct DylibCommand: Command {
    
    public typealias RawValue = dylib_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var name: String { readLCString(\.dylib.name) }
    
    public var strings: any Sequence<String> { [name] }
    
    public var timestamp: Date {
        Date(timeIntervalSince1970: Double(pointer.dylib.timestamp.swapping(needsSwapping)))
    }
    
    public var currentVersion: Version {
        .init(rawValue: pointer.dylib.current_version.swapping(needsSwapping))
    }
    
    public var compatibilityVersion: Version {
        .init(rawValue: pointer.dylib.compatibility_version.swapping(needsSwapping))
    }
    
    public var description: String { "\(defaultDescription) - \(name) @ \(timestamp), v\(currentVersion) (+v\(compatibilityVersion))" }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

//
//  File.swift
//
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public struct DylibCommand: Command {
    
    public typealias RawValue = dylib_command
    
    public static func matches(_ cmd: UInt32) -> Bool {
        return cmd == LC_LOAD_DYLIB || cmd == LC_LOAD_WEAK_DYLIB || cmd == LC_ID_DYLIB || cmd == LC_LOAD_UPWARD_DYLIB || cmd == LC_REEXPORT_DYLIB
    }
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var name: String { readLCString(\.dylib.name) }
    
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

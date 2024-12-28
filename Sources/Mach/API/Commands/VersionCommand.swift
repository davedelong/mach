//
//  File.swift
//
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public struct SourceVersionCommand: Command {
    
    public typealias RawValue = source_version_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var version: Version { .init(rawValue: pointer.version.swapping(needsSwapping)) }
    
    public var description: String { "\(defaultDescription) - version: \(version)"}
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
}

public struct BuildVersionCommand: Command {
    
    public typealias RawValue = build_version_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var platform: Platform { .init(rawValue: pointer.platform.swapping(needsSwapping)) }
    public var minimumOS: Version { .init(rawValue: pointer.minos.swapping(needsSwapping)) }
    public var sdk: Version { .init(rawValue: pointer.sdk.swapping(needsSwapping)) }
    
    public var description: String { "\(defaultDescription) - platform: \(platform), minOS: \(minimumOS), sdk: \(sdk)"}
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
    public var tools: any Collection<BuildToolVersion> {
        let numberOfTools = pointer.ntools
        let toolStart = pointer.advanced(by: MemoryLayout<build_version_command>.size).rebound(to: build_tool_version.self)
        return collection(count: numberOfTools, startingFrom: toolStart).map { ptr in
            BuildToolVersion(header: self.header, pointer: ptr)
        }
    }
}

public struct BuildToolVersion: CustomStringConvertible {
    
    public var tool: BuildTool
    public var version: Version
    
    public var description: String { "\(tool.description) @ v\(version)" }
    
    internal init(header: Header, pointer: Pointer<build_tool_version>) {
        self.tool = BuildTool(rawValue: pointer.tool.swapping(header.needsSwapping))
        self.version = Version(rawValue: pointer.version.swapping(header.needsSwapping))
    }
    
}

public struct BuildTool: CustomStringConvertible {
    
    public static let clang = Self(rawValue: UInt32(TOOL_CLANG))
    public static let swift = Self(rawValue: UInt32(TOOL_SWIFT))
    public static let ld = Self(rawValue: UInt32(TOOL_LD))
    public static let lld = Self(rawValue: UInt32(TOOL_LLD))
    
    public static let metal = Self(rawValue: UInt32(TOOL_METAL))
    public static let airLLD = Self(rawValue: UInt32(TOOL_AIRLLD))
    public static let airNT = Self(rawValue: UInt32(TOOL_AIRNT))
    public static let airNTPlugin = Self(rawValue: UInt32(TOOL_AIRNT_PLUGIN))
    public static let airPack = Self(rawValue: UInt32(TOOL_AIRPACK))
    public static let gpuArchiver = Self(rawValue: UInt32(TOOL_GPUARCHIVER))
    public static let metalFramework = Self(rawValue: UInt32(TOOL_METAL_FRAMEWORK))
    
    public let rawValue: UInt32
    
    public var description: String {
        buildToolNames[rawValue] ?? "unknown(\(rawValue))"
    }
    
}

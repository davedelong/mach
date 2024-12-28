//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public struct Platform: CustomStringConvertible {
    public static let unknown = Platform(rawValue: UInt32(PLATFORM_UNKNOWN))
    public static let any = Platform(rawValue: PLATFORM_ANY)
    public static let macOS = Platform(rawValue: UInt32(PLATFORM_MACOS))
    public static let iOS = Platform(rawValue: UInt32(PLATFORM_IOS))
    public static let tvOS = Platform(rawValue: UInt32(PLATFORM_TVOS))
    public static let watchOS = Platform(rawValue: UInt32(PLATFORM_WATCHOS))
    public static let bridgeOS = Platform(rawValue: UInt32(PLATFORM_BRIDGEOS))
    public static let macCatalyst = Platform(rawValue: UInt32(PLATFORM_MACCATALYST))
    public static let iOSSimulator = Platform(rawValue: UInt32(PLATFORM_IOSSIMULATOR))
    public static let tvOSSimulator = Platform(rawValue: UInt32(PLATFORM_TVOSSIMULATOR))
    public static let watchOSSimulator = Platform(rawValue: UInt32(PLATFORM_WATCHOSSIMULATOR))
    public static let driverKit = Platform(rawValue: UInt32(PLATFORM_DRIVERKIT))
    public static let visionOS = Platform(rawValue: UInt32(PLATFORM_VISIONOS))
    public static let visionOSSimulator = Platform(rawValue: UInt32(PLATFORM_VISIONOSSIMULATOR))
    public static let firmware = Platform(rawValue: UInt32(PLATFORM_FIRMWARE))
    public static let sepOS = Platform(rawValue: UInt32(PLATFORM_SEPOS))
    
    public let rawValue: UInt32
    
    public var description: String {
        return platformNames[rawValue] ?? "unknown (\(rawValue))"
    }
    
}


private let platformNames: Dictionary<UInt32, String> = [
    UInt32(PLATFORM_UNKNOWN): "unknown",
    PLATFORM_ANY: "any",
    UInt32(PLATFORM_MACOS): "macOS",
    UInt32(PLATFORM_IOS): "iOS",
    UInt32(PLATFORM_TVOS): "tvOS",
    UInt32(PLATFORM_WATCHOS): "watchOS",
    UInt32(PLATFORM_BRIDGEOS): "bridgeOS",
    UInt32(PLATFORM_MACCATALYST): "macCatalyst",
    UInt32(PLATFORM_IOSSIMULATOR): "iOSSimulator",
    UInt32(PLATFORM_TVOSSIMULATOR): "tvOSSimulator",
    UInt32(PLATFORM_WATCHOSSIMULATOR): "watchOSSimulator",
    UInt32(PLATFORM_DRIVERKIT): "driverKit",
    UInt32(PLATFORM_VISIONOS): "visionOS",
    UInt32(PLATFORM_VISIONOSSIMULATOR): "visionOSSimulator",
    UInt32(PLATFORM_FIRMWARE): "firmware",
    UInt32(PLATFORM_SEPOS): "sepOS",
]

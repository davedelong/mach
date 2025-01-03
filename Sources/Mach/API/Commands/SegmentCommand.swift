//
//  File.swift
//
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public struct SegmentCommand: Command {
    
    public typealias RawValue = segment_command
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var description: String { "\(defaultDescription) - \(name) - \(sectionCount) sections" }
    
    private var is64Bit: Bool { self.commandType.rawValue == LC_SEGMENT_64 }
    
    public var strings: any Sequence<String> {
        let textSections = sections.filter(\.likelyContainsStrings)
        return textSections.flatMap { section in
            return StringTable(start: section.dataPointer, size: section.dataSize)
        }
    }
    
    public var name: String {
        // 32 and 64-bit segments have the same segname size
        return pointer.withTypedPointer { ptr in
            guard let namePtr = ptr.pointer(to: \.segname.0) else { return "" }
            return String(cString: namePtr, maxLength: 16) ?? ""
        }
    }
    
    public var sectionCount: Int {
        if is64Bit {
            return Int(pointer.rebound(to: segment_command_64.self).nsects.swapping(needsSwapping))
        } else {
            return Int(pointer.nsects.swapping(needsSwapping))
        }
    }
    
    public var sections: any Collection<Section> {
        if is64Bit {
            let cmd = pointer.rebound(to: segment_command_64.self)
            let sectionCount = cmd.nsects.swapping(needsSwapping)
            let sectionStart: Pointer<section_64> = pointer.advanced(by: MemoryLayout<segment_command_64>.size)
            return collection(count: sectionCount, state: sectionStart, next: { state in
                defer { state = state.advanced(by: MemoryLayout<section_64>.size) }
                return Section(header: header, pointer: state.rebound())
            })
        } else {
            let sectionCount = pointer.nsects.swapping(needsSwapping)
            let sectionStart: Pointer<section> = pointer.advanced(by: MemoryLayout<segment_command>.size)
            return collection(count: sectionCount, state: sectionStart, next: { state in
                defer { state = state.advanced(by: MemoryLayout<section>.size) }
                return Section(header: header, pointer: state)
            })
        }
    }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
    internal var vmRange: Range<UInt64> {
        if is64Bit {
            let p = pointer.rebound(to: segment_command_64.self)
            let offset = UInt64(p.vmaddr.swapping(needsSwapping))
            let size = UInt64(p.vmsize.swapping(needsSwapping))
            
            return offset ..< (offset + size)
        } else {
            let offset = UInt64(pointer.vmaddr.swapping(needsSwapping))
            let size = UInt64(pointer.vmsize.swapping(needsSwapping))
            return offset ..< (offset + size)
        }
    }
    
    internal var fileRange: Range<UInt64> {
        if is64Bit {
            let p = pointer.rebound(to: segment_command_64.self)
            let offset = UInt64(p.fileoff.swapping(needsSwapping))
            let size = UInt64(p.filesize.swapping(needsSwapping))
            return offset ..< (offset + size)
        } else {
            let offset = UInt64(pointer.fileoff.swapping(needsSwapping))
            let size = UInt64(pointer.filesize.swapping(needsSwapping))
            return offset ..< (offset + size)
        }
    }
    
}

public struct Section: MachObject {
    
    let header: Header
    public let pointer: Pointer<section>
    
    internal var flags: UInt32 {
        if header.is64Bit {
            let pointer = pointer.rebound(to: section_64.self)
            return pointer.flags.swapping(header.needsSwapping)
        } else {
            return pointer.flags.swapping(header.needsSwapping)
        }
    }
    
    public var segmentName: String {
        // 32 and 64-bit segments have the same segname size
        return pointer.withTypedPointer { ptr in
            guard let namePtr = ptr.pointer(to: \.segname.0) else { return "" }
            return String(cString: namePtr, maxLength: 16) ?? ""
        }
    }
    
    public var sectionName: String {
        // 32 and 64-bit segments have the same segname size
        return pointer.withTypedPointer { ptr in
            guard let namePtr = ptr.pointer(to: \.sectname.0) else { return "" }
            return String(cString: namePtr, maxLength: 16) ?? ""
        }
    }
    
    public var name: String { segmentName + "." + sectionName }
    
    internal var likelyContainsStrings: Bool {
        if self.sectionType == .cStringLiterals { return true }
        if self.name == "__TEXT.__swift5_reflstr" { return true }
        return false
    }
    
    public var sectionType: SectionType {
        return SectionType(rawValue: UInt8(self.flags & UInt32(SECTION_TYPE)))
    }
    
    public var sectionAttributes: SectionAttributes {
        return SectionAttributes(rawValue: self.flags & SECTION_ATTRIBUTES)
    }
    
    public var description: String { "\(defaultDescription): \(name) (\(sectionType), \(sectionAttributes))" }
    
    public var dataPointer: Pointer<UInt8> {
        if header.is64Bit {
            let offset = pointer.rebound(to: section_64.self).offset.swapping(header.needsSwapping)
            return header.pointer(at: offset)
        } else {
            let offset = pointer.offset.swapping(header.needsSwapping)
            return header.pointer(at: offset)
        }
    }
    
    public var dataSize: Int {
        if header.is64Bit {
            return Int(pointer.rebound(to: section_64.self).size.swapping(header.needsSwapping))
        } else {
            return Int(pointer.size.swapping(header.needsSwapping))
        }
    }
    
}

public struct SectionType: RawRepresentable, CustomStringConvertible {
    public static let regular = SectionType(rawValue: UInt8(S_REGULAR))
    public static let zeroFill = SectionType(rawValue: UInt8(S_ZEROFILL))
    public static let cStringLiterals = SectionType(rawValue: UInt8(S_CSTRING_LITERALS))
    public static let fourByteLiterals = SectionType(rawValue: UInt8(S_4BYTE_LITERALS))
    public static let eightByteLiterals = SectionType(rawValue: UInt8(S_8BYTE_LITERALS))
    public static let literalPointers = SectionType(rawValue: UInt8(S_LITERAL_POINTERS))
    public static let nonLazySymbolPointers = SectionType(rawValue: UInt8(S_NON_LAZY_SYMBOL_POINTERS))
    public static let lazySymbolPointers = SectionType(rawValue: UInt8(S_LAZY_SYMBOL_POINTERS))
    public static let symbolStubs = SectionType(rawValue: UInt8(S_SYMBOL_STUBS))
    public static let modInitFunctionPointers = SectionType(rawValue: UInt8(S_MOD_INIT_FUNC_POINTERS))
    public static let modTermFunctionPointers = SectionType(rawValue: UInt8(S_MOD_TERM_FUNC_POINTERS))
    public static let coalesced = SectionType(rawValue: UInt8(S_COALESCED))
    public static let gbZerofill = SectionType(rawValue: UInt8(S_GB_ZEROFILL))
    public static let interposing = SectionType(rawValue: UInt8(S_INTERPOSING))
    public static let sixteenByteLiterals = SectionType(rawValue: UInt8(S_16BYTE_LITERALS))
    public static let dtraceObjectFormat = SectionType(rawValue: UInt8(S_DTRACE_DOF))
    public static let lazyDylibSymbolPointers = SectionType(rawValue: UInt8(S_LAZY_DYLIB_SYMBOL_POINTERS))
    public static let threadLocalRegular = SectionType(rawValue: UInt8(S_THREAD_LOCAL_REGULAR))
    public static let threadLocalZerofill = SectionType(rawValue: UInt8(S_THREAD_LOCAL_ZEROFILL))
    public static let threadLocalVariables = SectionType(rawValue: UInt8(S_THREAD_LOCAL_VARIABLES))
    public static let threadLocalVariablePointers = SectionType(rawValue: UInt8(S_THREAD_LOCAL_VARIABLE_POINTERS))
    public static let threadLocalInitFunctionPointers = SectionType(rawValue: UInt8(S_THREAD_LOCAL_INIT_FUNCTION_POINTERS))
    public static let initFunctionOffsets = SectionType(rawValue: UInt8(S_INIT_FUNC_OFFSETS))
    
    public let rawValue: UInt8
    
    public var description: String {
        return sectionTypeNames[rawValue] ?? "unknown (\(rawValue))"
    }
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

public struct SectionAttributes: OptionSet, CustomStringConvertible {
    public static let pureInstructions = Self(rawValue: S_ATTR_PURE_INSTRUCTIONS)
    public static let noTableOfContents = Self(rawValue: UInt32(S_ATTR_NO_TOC))
    public static let stripStaticSymbols = Self(rawValue: UInt32(S_ATTR_STRIP_STATIC_SYMS))
    public static let noDeadStrip = Self(rawValue: UInt32(S_ATTR_NO_DEAD_STRIP))
    public static let liveSupport = Self(rawValue: UInt32(S_ATTR_LIVE_SUPPORT))
    public static let selfModifyingCode = Self(rawValue: UInt32(S_ATTR_SELF_MODIFYING_CODE))
    public static let debug = Self(rawValue: UInt32(S_ATTR_DEBUG))
    public static let someInstructions = Self(rawValue: UInt32(S_ATTR_SOME_INSTRUCTIONS))
    public static let externalRelocationEntries = Self(rawValue: UInt32(S_ATTR_EXT_RELOC))
    public static let localRelocationEntries = Self(rawValue: UInt32(S_ATTR_LOC_RELOC))
    
    public let rawValue: UInt32
    
    public var description: String {
        var copy = self
        var names = Array<String>()
        for (known, name) in sectionAttributeNames {
            if copy.remove(known) == known { names.append(name) }
        }
        if copy != [] { names.append("unknown (\(copy.rawValue))") }
        return "[" + names.joined(separator: ", ") + "]"
    }
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
}

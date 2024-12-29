// The Swift Programming Language
// https://docs.swift.org/swift-book

import MachO
import MachO.dyld.utils

public struct Header: CustomStringConvertible, MachObject {
    
    public let pointer: Pointer<mach_header>
    
    internal var magic: UInt32 { pointer.magic }
    internal var is32Bit: Bool { magic == MH_MAGIC || magic == MH_CIGAM }
    internal var is64Bit: Bool { magic == MH_MAGIC_64 || magic == MH_CIGAM_64 }
    internal var needsSwapping: Bool { magic == MH_CIGAM || magic == MH_CIGAM_64 }
    
    public init?(pointer: Pointer<RawValue>) {
        self.pointer = pointer
        guard is32Bit || is64Bit else { return nil }
    }
    
    public var name: String { pointer.name }
    
    public var fileType: FileType {
        let raw = pointer.filetype.swapping(needsSwapping)
        return FileType(rawValue: Int32(raw))
    }
    
    public var cpuType: Int32 { pointer.cputype.swapping(self.needsSwapping) }
    
    public var cpuSubType: Int32 { pointer.cpusubtype.swapping(self.needsSwapping) }
    
    public var architectureName: String? {
        return withTypedPointer { ptr in
            guard let raw = macho_arch_name_for_mach_header(ptr) else { return nil }
            return String(cString: raw)
        }
    }
    
    public var description: String { "Header { \(pointer.fullDescription) }" }
    
    public var commands: any Collection<any Command> {
        let count = self.pointer.ncmds
        let headerSize = self.is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
        let pointer: Pointer<load_command> = self.pointer.advanced(by: headerSize)
        let swap = self.needsSwapping
        
        return collection(count: count, state: pointer, next: { ptr in
            let cmd = ptr.cmd.swapping(swap)
            let cmdType = command(for: cmd)
            let command = cmdType.init(header: self, commandPointer: ptr)
            ptr = ptr.advanced(by: ptr.cmdsize.swapping(swap))
            return command
        })
    }
    
}

public struct FileType: RawRepresentable, CustomStringConvertible {
    
    /// relocatable object file
    public static let object = FileType(rawValue: MH_OBJECT)
    
    /// demand paged executable file
    public static let executable = FileType(rawValue: MH_EXECUTE)
    
    /// fixed VM shared library file
    public static let fixedVMSharedLibrary = FileType(rawValue: MH_FVMLIB)
    
    /// core file
    public static let core = FileType(rawValue: MH_CORE)
    
    /// preloaded executable file
    public static let preloadedExecutable = FileType(rawValue: MH_PRELOAD)
    
    /// dynamically bound shared library
    public static let dynamicLibrary = FileType(rawValue: MH_DYLIB)
    
    /// dynamic link editor
    public static let dynamicLinkEditor = FileType(rawValue: MH_DYLINKER)
    
    /// dynamically-bound bundle file
    public static let bundle = FileType(rawValue: MH_BUNDLE)
    
    /// shared library stub for static linking only, no section contents
    public static let dynamicLibraryStubs = FileType(rawValue: MH_DYLIB_STUB)
    
    /// companion file with only debug sections
    public static let debugSymbols = FileType(rawValue: MH_DSYM)
    
    /// x86_64 kexts
    public static let kextBundle = FileType(rawValue: MH_KEXT_BUNDLE)
    
    /// a file composed of other Mach-Os to be run in the same userspace sharing a single linkedit.
    public static let fileSet = FileType(rawValue: MH_FILESET)
    
    /// gpu program
    public static let gpuExecutable = FileType(rawValue: MH_GPU_EXECUTE)
    
    /// gpu support functions
    public static let gpuDynamicLibrary = FileType(rawValue: MH_GPU_DYLIB)
    
    public let rawValue: Int32
    
    public var description: String { fileTypeNames[rawValue] ?? "unknown(\(rawValue))" }
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
}

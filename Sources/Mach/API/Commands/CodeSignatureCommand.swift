//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public struct CodeSignatureCommand: Command {
    
    public typealias RawValue = linkedit_data_command
    
    public static func matches(_ cmd: UInt32) -> Bool { cmd == LC_CODE_SIGNATURE }
    
    public let header: Header
    
    public let commandPointer: Pointer<load_command>
    
    public var description: String {
        if let codeSignature {
            return "\(defaultDescription) - \(codeSignature)"
        } else {
            return defaultDescription
        }
    }
    
    public init(header: Header, commandPointer: Pointer<load_command>) {
        self.header = header
        self.commandPointer = commandPointer
    }
    
    public var dataSize: UInt32 {
        return pointer.datasize.swapping(needsSwapping)
    }
    
    public var dataPointer: Pointer<UInt8>? {
        guard dataSize > 0 else { return nil }
        
        let offset = pointer.dataoff.swapping(needsSwapping)
        return header.pointer.advanced(by: offset)
    }
    
    public var codeSignature: Dictionary<String, Any>? {
        guard let dataPointer else { return nil }
        
        // lc_code_sig reads from dataPointer
        let superBlob = dataPointer.rebound(to: SuperBlob.self)
        guard superBlob.magic.bigEndian == CSMAGIC_EMBEDDED_SIGNATURE else {
            return nil
        }
        
        var signature = Dictionary<String, Any>()
        signature["ARCH"] = "CPU type: (\(header.cpuType),\(header.cpuSubType))"
        
        let indexPointer = dataPointer.advanced(by: MemoryLayout<SuperBlob>.size)
        
        let numberOfBlobs = superBlob.count.bigEndian
        let indexes = collection(of: BlobIndex.self, count: numberOfBlobs, startingFrom: indexPointer)
        
        for index in indexes {
            let offset = index.offset.bigEndian
            let blobHeader: Pointer<BlobHeader> = dataPointer.advanced(by: Int(offset))
            
            let magic = blobHeader.magic.bigEndian
            let length = blobHeader.length.bigEndian
            
            switch magic {
                case CSMAGIC_REQUIREMENTS:
                    //write_data("requirements", bytes, length);
                    break;
                case CSMAGIC_CODEDIRECTORY:
                    //write_data("codedir", bytes, length);
                    let cd = blobHeader.rebound(to: CS_CodeDirectory.self)
                    guard cd.version.bigEndian >= 0x20001 else { break }
                    guard cd.version.bigEndian <= 0x2F000 else { break }
                    guard cd.hashSize.bigEndian == 20 else { break }
                    guard cd.hashType.bigEndian == 1 else { break }
                    
                    signature["CodeDirectory"] = blobHeader.copyBytes(maxLength: Int(length))
                    
                    let hashOffset = cd.hashOffset.bigEndian
                    let hashSize = cd.hashSize.bigEndian
                    let entitlementSlot: UInt32 = 5
                    
                    if cd.nSpecialSlots.bigEndian >= entitlementSlot {
                        let ptr = blobHeader.advanced(by: Int(hashOffset)).advanced(by: -Int(entitlementSlot * UInt32(hashSize)))
                        
                        signature["EntitlementsCDHash"] = ptr.copyBytes(maxLength: Int(hashSize))
                    }
                case 0xfade0b01:
                    //write_data("signed", lc_code_signature, bytes-lc_code_signature);
                    guard length > 8 else { break }
                    let data = blobHeader.advanced(by: 8)
                    signature["SignedData"] = data.copyBytes(maxLength: Int(length - 8))
                    
                case 0xfade7171:
                    guard length > 8 else { break }
                    #warning("TODO: sha1 the blob")
                    signature["EntitlementsHash"] = nil // SHA1 of the entire blob
                    let data = blobHeader.advanced(by: 8)
                    signature["Entitlements"] = data.copyBytes(maxLength: Int(length - 8))
                default:
                    break
            }
        }
        
        return signature
    }
    
    public var entitlementsData: Data? {
        return self.codeSignature?["Entitlements"] as? Data
    }
    
    public var entitlements: Dictionary<String, Any>? {
        guard let data = entitlementsData else { return nil }
        let obj = try? PropertyListSerialization.propertyList(from: data, format: nil)
        return obj as? Dictionary<String, Any>
    }
}

// adapted from https://github.com/apple-oss-distributions/Security/blob/main/SecurityTool/sharedTool/codesign.c

/*
 * Structures of an embedded signature
 *
 * the structures always use big endianness
 * the .c file linked above uses ntohl() to swap the numbers
 * from big endian to host endian
 */

private let CSMAGIC_REQUIREMENT: UInt32    = 0xfade0c00        /* single Requirement blob */
private let CSMAGIC_REQUIREMENTS: UInt32 = 0xfade0c01        /* Requirements vector (internal requirements) */
private let CSMAGIC_CODEDIRECTORY: UInt32 = 0xfade0c02        /* CodeDirectory blob */
private let CSMAGIC_EMBEDDED_SIGNATURE: UInt32 = 0xfade0cc0 /* embedded form of signature data */
private let CSSLOT_CODEDIRECTORY: UInt32 = 0                /* slot index for CodeDirectory */

private struct SuperBlob {
    let magic: UInt32 /* magic number */
    let length: UInt32 /* total length of SuperBlob */
    let count: UInt32 /* number of index entries following */
    /* followed by \(count) BlobIndexes in no particular order as indicated by offsets in index */
}

private struct BlobIndex {
    let type: UInt32
    let offset: UInt32
}

private struct BlobHeader {
    let magic: UInt32
    let length: UInt32
}

private struct CS_CodeDirectory {
    let magic: UInt32                    /* magic number (CSMAGIC_CODEDIRECTORY) */
    let length: UInt32                /* total length of CodeDirectory blob */
    let version: UInt32                /* compatibility version */
    let flags: UInt32                    /* setup and mode flags */
    let hashOffset: UInt32            /* offset of hash slot element at index zero */
    let identOffset: UInt32            /* offset of identifier string */
    let nSpecialSlots: UInt32            /* number of special hash slots */
    let nCodeSlots: UInt32            /* number of ordinary (code) hash slots */
    let codeLimit: UInt32                /* limit to main image signature range */
    let hashSize: UInt8                /* size of each hash in bytes */
    let hashType: UInt8                /* type of hash (cdHashType* constants) */
    let spare1: UInt8                    /* unused (must be zero) */
    let pageSize: UInt8                /* log2(page size in bytes); 0 => infinite */
    let spare2: UInt32                /* unused (must be zero) */
    /* followed by dynamic content as located by offset fields above */
}


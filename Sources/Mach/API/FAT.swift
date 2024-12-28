//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation
import MachO

public struct FAT {
    
    public let headers: Array<Header>
    
    public init?(file: URL) {
        guard let image = ImageReference(file: file) else { return nil }
        let fat = Pointer<fat_header>(image: image, offset: 0)
        self.init(fat: fat)
    }
    
    private init?(fat: Pointer<fat_header>) {
        var headers = Array<Header>()
        
        let magic = fat.magic
        if magic == FAT_MAGIC || magic == FAT_CIGAM || magic == FAT_MAGIC_64 || magic == FAT_CIGAM_64 {
            // this is a fat header
            let is32Bit = (magic == FAT_MAGIC || magic == FAT_CIGAM)
            
            let numberOfArches = fat.nfat_arch.bigEndian
            var archPointer: Pointer<fat_arch> = fat.advanced(by: MemoryLayout<fat_header>.size)
            let archSize = is32Bit ? MemoryLayout<fat_arch>.size : MemoryLayout<fat_arch_64>.size
            
            for _ in 0 ..< numberOfArches {
                var machHeader: Header?
                if is32Bit {
                    let thisArch = archPointer
                    let offset = Int(thisArch.offset)
                    machHeader = Header(pointer: thisArch.pointer(at: offset))
                } else {
                    let thisArch = archPointer.rebound(to: fat_arch_64.self)
                    let offset = Int(thisArch.offset)
                    machHeader = Header(pointer: thisArch.pointer(at: offset))
                }
                
                if let machHeader { headers.append(machHeader) }
                archPointer = archPointer.advanced(by: archSize)
            }
            
        }
        
        if headers.isEmpty {
            // maybe this is a base mach-o object
            if let header = Header(pointer: fat.rebound(to: mach_header.self)) {
                headers = [header]
            }
        }
        
        if headers.isEmpty {
            return nil
        }
        
        self.headers = headers
    }
    
}


extension FAT {
    
    public struct Arch {
        
    }
    
}
//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation
import MachO
import MachO.dyld.utils

public struct Dyld {
    
    public static var executable: Dyld.Image {
        return images.first(where: { $0.header.fileType == .executable })!
    }
    
    public static var images: some Collection<Dyld.Image> {
        let count = _dyld_image_count()
        return collection(count: count, next: { index -> Dyld.Image in
            let rawName = _dyld_get_image_name(index)!
            let rawHeader = _dyld_get_image_header(index)!
            
            let slide = _dyld_get_image_vmaddr_slide(index)
            let image = ImageReference(name: String(cString: rawName), baseAddress: rawHeader, slide: slide)
            let header = Header(pointer: .init(image: image, offset: 0))!
            return Dyld.Image(name: String(cString: rawName), header: header)
        })
    }
    
    public static func thisImage(_ image: UnsafeRawPointer = #dsohandle) -> Dyld.Image {
        let sorted = images.sorted(by: { $0.header.pointer.base < $1.header.pointer.base }).reversed()
        return sorted.first(where: { $0.header.pointer.base <= image })!
    }
    
    public struct Image: CustomStringConvertible {
        public let name: String
        public let header: Mach.Header
        
        public var description: String { "\(name): \(header)" }
        
        internal init(name: String, header: Mach.Header) {
            self.name = name
            self.header = header
        }
    }
}


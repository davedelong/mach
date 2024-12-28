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
    
    public static var executable: Header {
        return images.first(where: { $0.fileType == .executable })!
    }
    
    public static var images: some Collection<Header> {
        let count = _dyld_image_count()
        return collection(count: count, next: { index -> Header in
            let rawName = _dyld_get_image_name(index)!
            let rawHeader = _dyld_get_image_header(index)!
            
            let slide = _dyld_get_image_vmaddr_slide(index)
            let image = ImageReference(name: String(cString: rawName), baseAddress: rawHeader, slide: slide)
            return Header(pointer: .init(image: image, offset: 0))!
        })
    }
    
    public static func thisImage(_ image: UnsafeRawPointer = #dsohandle) -> Header {
        let sorted = images.sorted(by: { $0.pointer.base < $1.pointer.base }).reversed()
        return sorted.first(where: { $0.pointer.base <= image })!
    }
}


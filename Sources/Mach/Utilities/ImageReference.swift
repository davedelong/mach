//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

internal final class ImageReference: Sendable, CustomStringConvertible {
    
    private enum Source: @unchecked Sendable {
        case loadedImage(UnsafeRawPointer)
        case mmapFile(Data)
    }
    
    internal let name: String
    private let source: Source
    private let slide: Int
    
    var description: String {
        switch source {
            case .loadedImage(let ptr): return "\(name) @ \(ptr)"
            case .mmapFile(_): return name
        }
    }
    
    init(name: String, baseAddress: UnsafeRawPointer, slide: Int) {
        self.name = name
        self.source = .loadedImage(baseAddress)
        self.slide = slide
    }
    
    init?(file: URL) {
        guard file.isFileURL else { return nil }
        guard let data = try? Data(contentsOf: file, options: [.mappedIfSafe]) else { return nil }
        
        self.name = file.path
        self.source = .mmapFile(data)
        self.slide = 0
    }
    
    func withRawPointer<T>(at offset: Int = 0, perform body: (UnsafeRawPointer) throws -> T) rethrows -> T {
        switch source {
            case .loadedImage(let baseAddress):
                let raw = baseAddress.advanced(by: offset)
                return try body(raw)
                
            case .mmapFile(let data):
                return try data.withUnsafeBytes { (bufferPointer: UnsafeRawBufferPointer) in
                    let raw = bufferPointer.baseAddress!.advanced(by: offset)
                    return try body(raw)
                }
        }
    }
    
    func withPointer<T, V>(of type: T.Type = T.self, at offset: Int = 0, perform body: (UnsafePointer<T>) throws -> V) rethrows -> V {
        return try withRawPointer(at: offset, perform: { raw in
            return try body(raw.assumingMemoryBound(to: type))
        })
    }
    
}

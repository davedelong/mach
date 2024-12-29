//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

@dynamicMemberLookup
public struct Pointer<T>: Sendable, CustomStringConvertible, Comparable {
    public static func == (lhs: Self, rhs: Self) -> Bool { lhs.image === rhs.image && lhs.offset == rhs.offset }
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.image === rhs.image && lhs.offset < rhs.offset }
    
    private let image: ImageReference
    private let offset: Int
    
    internal init(image: ImageReference, offset: Int) {
        self.image = image
        self.offset = offset
    }
    
    internal var base: UnsafeRawPointer { image.withRawPointer(at: offset, perform: { $0 }) }
    
    internal var name: String { image.name }
    
    internal var fullDescription: String {
        if offset != 0 {
            return "type: \(T.self), name: \(image), offset: \(offset)"
        } else {
            return "type: \(T.self), name: \(image)"
        }
    }
    
    public var description: String {
        if offset != 0 {
            return "type: \(T.self), offset: \(offset)"
        } else {
            return "type: \(T.self)"
        }
    }
    
    public var dereference: T { withTypedPointer(perform: { $0.pointee }) }
    
    public subscript<V>(dynamicMember keyPath: KeyPath<T, V>) -> V {
        return withTypedPointer(perform: {
            return $0.pointee[keyPath: keyPath]
        })
    }
    
    public func pointer<R>(of type: R.Type = R.self, at newOffset: some FixedWidthInteger) -> Pointer<R> {
        return Pointer<R>(image: image, offset: Int(newOffset))
    }
    
    public func advanced(by relative: some FixedWidthInteger) -> Pointer<T> {
        let newOffset = offset + Int(relative)
        guard newOffset >= 0 else { fatalError("Tried to advanced to negative offset") }
        return Pointer(image: image, offset: newOffset)
    }
    
    @_disfavoredOverload
    public func advanced<R>(by relative: some FixedWidthInteger) -> Pointer<R> {
        let newOffset = offset + Int(relative)
        guard newOffset >= 0 else { fatalError("Tried to advanced to negative offset") }
        return Pointer<R>(image: image, offset: newOffset)
    }
    
    public func rebound<R>(to type: R.Type = R.self) -> Pointer<R> {
        return Pointer<R>(image: image, offset: offset)
    }
    
    internal func withTypedPointer<R>(perform body: (UnsafePointer<T>) throws -> R) rethrows -> R {
        return try image.withPointer(at: offset, perform: body)
    }
    
    internal func withUntypedPointer<R>(perform body: (UnsafeRawPointer) throws -> R) rethrows -> R {
        return try image.withRawPointer(at: offset, perform: body)
    }
    
    internal func distance<R>(to other: Pointer<R>) -> Int {
        // the number in bytes to move from self to other
        // IOW, self.advanced(by: self.distance(to: other)) == other
        guard self.image === other.image else { fatalError("Cannot compare pointers from different images") }
        return other.offset - self.offset
    }
    
    internal func copyBytes() -> Data {
        return copyBytes(maxLength: MemoryLayout<T>.size)
    }
    
    internal func copyBytes(maxLength: Int) -> Data {
        let ptr = self.rebound(to: UInt8.self)
        return ptr.withTypedPointer(perform: { raw in
            let buffer = UnsafeBufferPointer(start: raw, count: maxLength)
            return Data(buffer: buffer)
        })
    }
}

//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

public protocol MachObject: CustomStringConvertible {
    associatedtype RawValue
    
    var pointer: Pointer<RawValue> { get }
}

extension MachObject {
    
    public var defaultDescription: String { pointer.description }
    
    public var description: String { defaultDescription }
    
    internal func withTypedPointer<T>(perform body: (UnsafePointer<RawValue>) throws -> T) rethrows -> T {
        return try self.pointer.withTypedPointer(perform: body)
    }
    
    internal func withTypedPointer<R, T>(of type: R.Type, perform body: (UnsafePointer<R>) throws -> T) rethrows -> T {
        return try self.pointer.withTypedPointer(perform: { ptr in
            return try ptr.withMemoryRebound(to: R.self, capacity: 1, body)
        })
    }
    
}

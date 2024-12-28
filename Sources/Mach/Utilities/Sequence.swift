//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/28/24.
//

import Foundation

extension Sequence {
    
    internal func eraseToAnySequence() -> AnySequence<Element> { AnySequence(inner: self) }
    
}

internal struct AnySequence<Element>: Sequence {
    
    internal struct Iterator: IteratorProtocol {
        
        fileprivate let _next: () -> Element?
        
        func next() -> Element? { _next() }
        
    }
    
    private let _makeIterator: () -> Iterator
    
    func makeIterator() -> Iterator { _makeIterator() }
    
    init(inner: any Sequence<Element>) {
        _makeIterator = {
            var innerIterator = inner.makeIterator() as any IteratorProtocol<Element>
            return Iterator(_next: { innerIterator.next() })
        }
    }
    
}

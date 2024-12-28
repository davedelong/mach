//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

import Foundation

extension Collection {
    
    func flatMap<T>(_ transform: (Element) throws -> any Sequence<T>) rethrows -> some Sequence<T> {
        return try self.flatMap { discretify(try transform($0)) }
    }
    
}

private func discretify<T>(_ sequence: any Sequence<T>) -> some Sequence<T> {
    var anyIterator: any IteratorProtocol<T> = sequence.makeIterator()
    let iterator = AnyIterator { anyIterator.next() }
    return IteratorSequence(iterator)
}

func collection<I: FixedWidthInteger, T, R>(of: T.Type = T.self, count: I, startingFrom start: Pointer<R>) -> Array<Pointer<T>> {
    
    let base = start.rebound(to: T.self)
    return collection(count: count, state: base, next: { state -> Pointer<T> in
        defer { state = state.advanced(by: MemoryLayout<T>.size) }
        return state
    })
}

func collection<I: FixedWidthInteger, T>(count: I, next: @escaping (I) -> T) -> Array<T> {
    return Array(UnfoldCollection(count: Int(count), initial: I.zero, next: { idx in
        defer { idx += 1 }
        return next(idx)
    }))
}

func collection<I: FixedWidthInteger, T, State>(count: I, state: State, next: @escaping (inout State) -> T) -> Array<T> {
    return Array(UnfoldCollection(count: Int(count), initial: state, next: next))
}

struct UnfoldCollection<Element, State>: Collection {
    typealias Index = Int
    
    let count: Int
    
    var startIndex: Int { 0 }
    var endIndex: Int { count }
    
    private let state: State
    private let next: (inout State) -> Element
    
    init(count: Int, initial: State, next: @escaping (inout State) -> Element) {
        self.count = count
        self.state = initial
        self.next = next
    }
    
    func index(after i: Int) -> Int { Swift.min(i + 1, endIndex) }
    
    subscript(position: Int) -> Element {
        var iterator = makeIterator()
        for _ in 0 ..< position { _ = iterator.next() }
        return iterator.next()!
    }
    
    func makeIterator() -> Iterator { Iterator(count: count, state: state, nextElement: next) }
    
    struct Iterator: IteratorProtocol {
        var current = 0
        let count: Int
        var state: State
        let nextElement: (inout State) -> Element
        
        mutating func next() -> Element? {
            guard current < count else { return nil }
            current += 1
            return nextElement(&state)
        }
    }
    
}

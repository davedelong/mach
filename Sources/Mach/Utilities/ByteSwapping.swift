//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/24.
//

extension FixedWidthInteger {
    
    func swapping(_ shouldSwap: Bool) -> Self {
        return shouldSwap ? self.byteSwapped : self
    }
    
}

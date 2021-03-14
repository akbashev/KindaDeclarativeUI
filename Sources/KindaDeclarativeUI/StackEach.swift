//
//  File.swift
//  
//
//  Created by Jaleel Akbashev on 14.03.21.
//

import UIKit

public struct StackEach<Data, ID, Content> where Data: RandomAccessCollection, ID: Hashable, Content: StackView {
    
    public let data: Data
    public let content: (Data.Element) -> Content
        
    init(data: Data, content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }
}

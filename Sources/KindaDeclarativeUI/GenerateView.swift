//
//  File.swift
//  
//
//  Created by Jaleel Akbashev on 14.03.21.
//

import UIKit

public struct GenerateView: StackView {
    public var body: UIView
    public var updateView: StackView.Update? = nil
    
    public init(_ generate: () -> UIView, updateView: StackView.Update? = nil) {
        let view = generate()
        self.body = view
        
        self.infiniteHeight = view.infiniteHeight
        self.infiniteWidth = view.infiniteWidth
    }
    
    public init(stack: () -> StackView, updateView: StackView.Update? = nil) {
        let view = stack().body
        self.body = view
        
        self.infiniteHeight = view.infiniteHeight
        self.infiniteWidth = view.infiniteWidth
    }
    
    public func update() {
        self.updateView?(self.body)
    }
}


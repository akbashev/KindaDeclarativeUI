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
    
    public func update() {
        self.updateView?(self.body)
    }
}

public protocol MapStackView {}

public extension MapStackView where Self: UIView {
    func map(_ closure: (Self) throws -> Void) rethrows -> StackView {
        try closure(self)
        return GenerateView {
            self
        }
    }
}

extension NSObject: MapStackView {}

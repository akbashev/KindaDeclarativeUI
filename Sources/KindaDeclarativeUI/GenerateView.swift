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
        self.body = generate()
    }
    
    public func update() {
        self.updateView?(self.body)
    }
}


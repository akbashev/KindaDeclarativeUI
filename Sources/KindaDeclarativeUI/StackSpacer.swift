//
//  StackView.swift
//  KindaDeclarativeUI
//
//  Created by Jaleel Akbashev on 17.07.20.
//  Copyright © 2020 Jaleel Akbashev. All rights reserved.
//

import UIKit

public struct StackSpacer: StackView {
    
    public let body: UIView
    
    var axis: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            switch self.axis {
            case .vertical:
                self.infiniteHeight = self.body.heightAnchorConstraint == nil
            default:
                self.infiniteWidth = self.body.widthAnchorConstraint == nil
            }
        }
    }
    
    public init() {
        self.body = StackSpacerView()
    }
}

class StackSpacerView: UIView {}

extension UIView {
    var widthAnchorConstraint: NSLayoutConstraint? {
        return self.constraints.filter({ $0.firstAttribute.rawValue == NSLayoutConstraint.Attribute.width.rawValue }).first
    }
    
    var heightAnchorConstraint: NSLayoutConstraint? {
        return self.constraints.filter({ $0.firstAttribute.rawValue == NSLayoutConstraint.Attribute.height.rawValue }).first
    }
}

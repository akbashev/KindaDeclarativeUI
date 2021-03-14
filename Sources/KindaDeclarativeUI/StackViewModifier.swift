//
//  StackViewModifiers.swift
//  KindaDeclarativeUI
//
//  Created by Jaleel Akbashev on 17.07.20.
//  Copyright © 2020 Jaleel Akbashev. All rights reserved.
//

import UIKit

protocol StackViewModifier {
    func modify(_ view: StackView) -> StackView
}

private extension StackView {
    func modifier(_ modifier: StackViewModifier) -> StackView {
        modifier.modify(self)
    }
}

private struct StackSizeModifier: StackViewModifier {
    
    private var width: CGFloat?
    private var height: CGFloat?
    
    init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
    }
    
    func modify(_ view: StackView) -> StackView {
        var view = view
        if let width = self.width {
            if width == CGFloat.infinity || width == CGFloat.greatestFiniteMagnitude {
                view.infiniteWidth = true
            } else {
              view.body.widthAnchor.constraint(equalToConstant: width).with(priority: .required - 1).isActive = true
            }
        }
        if let height = self.height {
            if height == CGFloat.infinity || height == CGFloat.greatestFiniteMagnitude {
                view.infiniteHeight = true
            } else {
                view.body.heightAnchor.constraint(equalToConstant: height).with(priority: .required - 1).isActive = true
            }
        }
        return view
    }
}

private struct StackBorderModifier: StackViewModifier {
    
    private var borderWidth: CGFloat?
    private var borderColor: CGColor?
    private var masksToBounds: Bool?
    
    init(borderWidth: CGFloat? = nil,
         borderColor: CGColor? = nil,
         masksToBounds: Bool? = nil) {
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.masksToBounds = masksToBounds
    }
    
    func modify(_ view: StackView) -> StackView {
        if let borderWidth = self.borderWidth {
            view.body.layer.borderWidth = borderWidth
        }
        if let borderColor = self.borderColor {
            view.body.layer.borderColor = borderColor
        }
        if let masksToBounds = self.masksToBounds {
            view.body.layer.masksToBounds = masksToBounds
        }
        return view
    }
}

private struct StackBackgroundColorModifier: StackViewModifier {
    
    private var backgroundColor: UIColor?
    
    init(backgroundColor: UIColor? = nil) {
        self.backgroundColor = backgroundColor
    }
    
    func modify(_ view: StackView) -> StackView {
        if let backgroundColor = self.backgroundColor {
          let backgroundView = UIView()
          backgroundView.backgroundColor = backgroundColor
          backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          view.body.insertSubview(backgroundView, at: 0)
        }
        return view
    }
}

private struct StackCornersModifier: StackViewModifier {
    
    private var cornerRadius: CGFloat?
    
    init(cornerRadius: CGFloat? = nil) {
        self.cornerRadius = cornerRadius
    }
    
    func modify(_ view: StackView) -> StackView {
        if let cornerRadius = self.cornerRadius {
            view.body.layer.cornerRadius = cornerRadius
        }
        return view
    }
}

private struct StackPaddingModifier: StackViewModifier {
    
    private let padding: UIEdgeInsets
    
    init(padding: UIEdgeInsets) {
        self.padding = padding
    }
    
    func modify(_ view: StackView) -> StackView {
        view.body.layoutMargins = padding
        return view
    }
}

public extension StackView {
    
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> StackView {
        let sizeModifier = StackSizeModifier(width: width, height: height)
        return sizeModifier.modify(self)
    }
    
    func border(width borderWidth: CGFloat,
                color borderColor: UIColor,
                masksToBounds: Bool = false) -> StackView {
        let borderModifier = StackBorderModifier(borderWidth: borderWidth,
                                                 borderColor: borderColor.cgColor,
                                                 masksToBounds: masksToBounds)
        return borderModifier.modify(self)
    }
    
    func borderWidth(_ borderWidth: CGFloat) -> StackView {
        let borderModifier = StackBorderModifier(borderWidth: borderWidth)
        return borderModifier.modify(self)
    }
    
    func borderColor(_ borderColor: UIColor) -> StackView {
        let borderModifier = StackBorderModifier(borderColor: borderColor.cgColor)
        return borderModifier.modify(self)
    }
  
    func backgroundColor(_ backgroundColor: UIColor?) -> StackView {
        let backgroundModifier = StackBackgroundColorModifier(backgroundColor: backgroundColor)
        return backgroundModifier.modify(self)
    }
    
    func masksToBounds(_ masksToBounds: Bool) -> StackView {
        let borderModifier = StackBorderModifier(masksToBounds: masksToBounds)
        return borderModifier.modify(self)
    }
    
    func cornerRadius(_ cornerRadius: CGFloat) -> StackView {
        let cornerModifier = StackCornersModifier(cornerRadius: cornerRadius)
        return cornerModifier.modify(self)
    }
    
    func padding(top: CGFloat = 16,
                 left: CGFloat = 16,
                 bottom: CGFloat = 16,
                 right: CGFloat = 16) -> StackView {
        let paddingModifier = StackPaddingModifier(padding: UIEdgeInsets(top: top,
                                                                         left: left,
                                                                         bottom: bottom,
                                                                         right: right))
        return paddingModifier.modify(self)
    }
}

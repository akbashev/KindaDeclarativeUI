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
                let identifier = "io.github.akbashev.stackview.anchorIdentifier.width"
                let constraint = view.body.constraint(withIdentifier: identifier) ?? view.body.widthAnchor.constraint(equalToConstant: width, identifier: identifier)
                constraint.constant = width
                constraint.isActive = true
            }
        }
        if let height = self.height {
            if height == CGFloat.infinity || height == CGFloat.greatestFiniteMagnitude {
                view.infiniteHeight = true
            } else {
                let identifier = "io.github.akbashev.stackview.anchorIdentifier.height"
                let constraint = view.body.constraint(withIdentifier: identifier) ?? view.body.heightAnchor.constraint(equalToConstant: height, identifier: identifier)
                constraint.constant = height
                constraint.isActive = true
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

private struct DebugModifier: StackViewModifier {
    
    private var color: UIColor

    init(color: UIColor) {
        self.color = color
    }
    
    func modify(_ view: StackView) -> StackView {
        @discardableResult
        func addBorder(view: UIView) -> StackView {
            view.recursiveSubviews.forEach {
                if $0.layer.borderWidth == 0 {
                    addBorder(view: $0)
                }
            }
            if view.layer.borderWidth == 0 {
                return view.border(width: 1, color: color)
            }
            return view
        }
        return addBorder(view: view.body)
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
        switch view.body {
        case is StackCollectionView:
            (view.body as? StackCollectionView)?.collectionView.contentInset = padding
            return view
        case is UIStackView:
            (view.body as? UIStackView)?.layoutMargins = padding
            return view
        case is StackEachView:
            (view.body as? StackEachView)?.stackViews.forEach { $0.padding(padding) }
            return view
        case is FlatStackView:
            (view.body as? FlatStackView)?.layoutMargins = padding
            return view
        case is PaddingView:
            (view.body as? PaddingView)?.layoutMargins = padding
            return view
        default:
            return PaddingStack(subview: view.body).padding(padding)
        }
    }
}

public struct AspectRatioModifier: StackViewModifier {
    
    public enum ContentMode {
        case fit, fill
    }
    
    private let aspectRatio: CGFloat?
    private let contentMode: ContentMode
    
    init(_ aspectRatio: CGFloat? = nil, contentMode: ContentMode) {
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
    }
    
    func modify(_ view: StackView) -> StackView {
        var view = view
        let identifier = "io.github.akbashev.stackview.anchorIdentifier.aspectRation"
        if contentMode == .fill {
            view.infiniteHeight = true
            view.infiniteWidth = true
        }
        if var constraint = view.body.constraint(withIdentifier: identifier) {
            constraint.isActive = false
            constraint = NSLayoutConstraint(item: view.body,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: view.body,
                                            attribute: .height,
                                            multiplier: aspectRatio ?? 1,
                                            constant: 0)
            constraint.isActive = true
        } else {
            let constraint = NSLayoutConstraint(item: view.body,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: view.body,
                                                attribute: .height,
                                                multiplier: aspectRatio ?? 1,
                                                constant: 0)
            constraint.identifier = identifier
            constraint.isActive = true
        }
        return view
    }
}

public extension StackView {
    
    @discardableResult
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> StackView {
        let sizeModifier = StackSizeModifier(width: width, height: height)
        return sizeModifier.modify(self)
    }
    
    @discardableResult
    func border(width borderWidth: CGFloat,
                color borderColor: UIColor,
                masksToBounds: Bool = false) -> StackView {
        let borderModifier = StackBorderModifier(borderWidth: borderWidth,
                                                 borderColor: borderColor.cgColor,
                                                 masksToBounds: masksToBounds)
        return borderModifier.modify(self)
    }
    
    @discardableResult
    func borderWidth(_ borderWidth: CGFloat) -> StackView {
        let borderModifier = StackBorderModifier(borderWidth: borderWidth)
        return borderModifier.modify(self)
    }
    
    @discardableResult
    func borderColor(_ borderColor: UIColor) -> StackView {
        let borderModifier = StackBorderModifier(borderColor: borderColor.cgColor)
        return borderModifier.modify(self)
    }
    
    @discardableResult
    func backgroundColor(_ backgroundColor: UIColor?) -> StackView {
        let backgroundModifier = StackBackgroundColorModifier(backgroundColor: backgroundColor)
        return backgroundModifier.modify(self)
    }
    
    @discardableResult
    func masksToBounds(_ masksToBounds: Bool) -> StackView {
        let borderModifier = StackBorderModifier(masksToBounds: masksToBounds)
        return borderModifier.modify(self)
    }
    
    @discardableResult
    func cornerRadius(_ cornerRadius: CGFloat) -> StackView {
        let cornerModifier = StackCornersModifier(cornerRadius: cornerRadius)
        return cornerModifier.modify(self)
    }
    
    @discardableResult
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
    
    @discardableResult
    func padding(_ padding: UIEdgeInsets) -> StackView {
        let paddingModifier = StackPaddingModifier(padding: padding)
        return paddingModifier.modify(self)
    }
    
    @discardableResult
    func padding(_ onePadding: CGFloat) -> StackView {
        let paddingModifier = StackPaddingModifier(padding: UIEdgeInsets(top: onePadding,
                                                                         left: onePadding,
                                                                         bottom: onePadding,
                                                                         right: onePadding))
        return paddingModifier.modify(self)
    }
    
    @discardableResult
    func aspectRatio(_ aspectRatio: CGFloat? = nil, contentMode: AspectRatioModifier.ContentMode) -> StackView {
        let modifier = AspectRatioModifier(aspectRatio, contentMode: contentMode)
        return modifier.modify(self)
    }
    
    @discardableResult
    func debug(_ color: UIColor = .yellow) -> StackView {
        let debugModifier = DebugModifier(color: color)
        return debugModifier.modify(self)
    }
}

fileprivate extension NSLayoutDimension {
    @objc func constraint(equalToConstant constant: CGFloat, identifier: String) -> NSLayoutConstraint {
        let constraint = self.constraint(equalToConstant: constant)
        constraint.identifier = identifier
        return constraint
    }
}

fileprivate extension UIView {
    func constraint(withIdentifier: String) -> NSLayoutConstraint? {
        return self.constraints.filter { $0.identifier == withIdentifier }.first
    }
}

private extension UIView {
    var recursiveSubviews: [UIView] {
        switch self {
        case is StackEachView:
            guard let stackViews = (self as? StackEachView)?.stackViews else { return [] }
            return stackViews.map { $0.body } + stackViews.flatMap { $0.body.recursiveSubviews }
        case is UIStackView:
            guard let arrangedSubviews = (self as? UIStackView)?.arrangedSubviews else { return [] }
            return arrangedSubviews.map { $0 } + arrangedSubviews.flatMap { $0.recursiveSubviews }
        case is StackCollectionView:
            guard let stackSubviews = (self as? StackCollectionView)?.stackSubviews else { return [] }
            return stackSubviews.map { $0.body } + stackSubviews.flatMap { $0.body.recursiveSubviews }
        default:
            return self.subviews + self.subviews.flatMap { $0.recursiveSubviews }
        }
    }
}

private struct PaddingStack: StackView {
    
    public var body: UIView
    
    init(subview: UIView) {
        let view = PaddingView()
        view.addSubview(subview)
        self.body = view
    }
}

private class PaddingView: UIView {
    
    private var _constraints: [NSLayoutConstraint] = []

    override func updateConstraints() {
        super.updateConstraints()

        NSLayoutConstraint.deactivate(_constraints)
        
        self.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            _constraints.append(contentsOf: [
                $0.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
                $0.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                $0.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
                $0.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            ])
        }
        
        NSLayoutConstraint.activate(_constraints)
    }
}

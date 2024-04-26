//
//  StackViewModifiers.swift
//  KindaDeclarativeUI
//
//  Created by Jaleel Akbashev on 17.07.20.
//  Copyright © 2020 Jaleel Akbashev. All rights reserved.
//

import UIKit

protocol StackViewModifier {
    @MainActor func modify(_ view: StackView) -> StackView
}

private extension StackView {
    func modifier(_ modifier: StackViewModifier) -> StackView {
        modifier.modify(self)
    }
}

@MainActor
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

@MainActor
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
        switch view.body {
        case is UIStackView:
            if #available(iOS 14, *) {
                if let borderWidth = self.borderWidth {
                    view.body.layer.borderWidth = borderWidth
                }
                if let borderColor = self.borderColor {
                    view.body.layer.borderColor = borderColor
                }
                if let masksToBounds = self.masksToBounds {
                    view.body.layer.masksToBounds = masksToBounds
                }
            } else {
                let backgroundView = view.body.subviews.first { $0 is BackgroundView } ?? BackgroundView()
                backgroundView.removeFromSuperview()
                if let borderWidth = self.borderWidth {
                    backgroundView.layer.borderWidth = borderWidth
                }
                if let borderColor = self.borderColor {
                    backgroundView.layer.borderColor = borderColor
                }
                if let masksToBounds = self.masksToBounds {
                    backgroundView.layer.masksToBounds = masksToBounds
                }
                backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                view.body.insertSubview(backgroundView, at: 0)
            }
        default:
            if let borderWidth = self.borderWidth {
                view.body.layer.borderWidth = borderWidth
            }
            if let borderColor = self.borderColor {
                view.body.layer.borderColor = borderColor
            }
            if let masksToBounds = self.masksToBounds {
                view.body.layer.masksToBounds = masksToBounds
            }
        }
        return view
    }
}

@MainActor
private struct StackBackgroundColorModifier: StackViewModifier {
    
    private var backgroundColor: UIColor?
    
    init(backgroundColor: UIColor? = nil) {
        self.backgroundColor = backgroundColor
    }
    
    func modify(_ view: StackView) -> StackView {
        if let backgroundColor = self.backgroundColor {
            switch view.body {
            case is UIStackView:
                if #available(iOS 14, *) {
                    view.body.backgroundColor = backgroundColor
                } else {
                    let backgroundView = view.body.subviews.first { $0 is BackgroundView } ?? BackgroundView()
                    backgroundView.removeFromSuperview()
                    backgroundView.backgroundColor = backgroundColor
                    backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    view.body.insertSubview(backgroundView, at: 0)
                }
            default:
                view.body.backgroundColor = backgroundColor
            }
        }
        return view
    }
}

@MainActor
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

@MainActor
private struct StackCornersModifier: StackViewModifier {
    
    private var cornerRadius: CGFloat?
    
    init(cornerRadius: CGFloat? = nil) {
        self.cornerRadius = cornerRadius
    }
    
    func modify(_ view: StackView) -> StackView {
        if let cornerRadius = self.cornerRadius {
            switch view.body {
            case is UIStackView:
                if #available(iOS 14, *) {
                    view.body.layer.cornerRadius = cornerRadius
                } else {
                    let backgroundView = view.body.subviews.first { $0 is BackgroundView } ?? BackgroundView()
                    backgroundView.removeFromSuperview()
                    backgroundView.layer.cornerRadius = cornerRadius
                    backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    view.body.insertSubview(backgroundView, at: 0)
                }
            default:
                view.body.layer.cornerRadius = cornerRadius
            }
        }
        return view
    }
}

@MainActor
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

@MainActor
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

@MainActor
private struct ShadowModifier: StackViewModifier {
    
    private let color: UIColor
    private let radius: CGFloat
    private let x: CGFloat
    private let y: CGFloat

    init(color: UIColor = UIColor(white: 0, alpha: 0.33), radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
    
    func modify(_ view: StackView) -> StackView {
        switch view.body {
        case is UIStackView:
            if #available(iOS 14, *) {
                view.body.layer.shadowColor = self.color.cgColor
                view.body.layer.shadowOpacity = Float(self.color.alphaComponent)
                view.body.layer.shadowOffset = UIOffset(horizontal: x, vertical: y).size
                view.body.layer.shadowRadius = self.radius
            } else {
                let backgroundView = view.body.subviews.first { $0 is BackgroundView } ?? BackgroundView()
                backgroundView.removeFromSuperview()
                backgroundView.layer.shadowColor = self.color.cgColor
                backgroundView.layer.shadowOpacity = Float(self.color.alphaComponent)
                backgroundView.layer.shadowOffset = UIOffset(horizontal: x, vertical: y).size
                backgroundView.layer.shadowRadius = self.radius
                backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                view.body.insertSubview(backgroundView, at: 0)
            }
        default:
            view.body.layer.shadowColor = self.color.cgColor
            view.body.layer.shadowOpacity = Float(self.color.alphaComponent)
            view.body.layer.shadowOffset = UIOffset(horizontal: x, vertical: y).size
            view.body.layer.shadowRadius = self.radius
        }
        return view
    }
}

@MainActor
private struct HiddenModifier: StackViewModifier {
    
    private let isHidden: Bool
    
    init(isHidden: Bool) {
        self.isHidden = isHidden
    }
    
    func modify(_ view: StackView) -> StackView {
        view.body.isHidden = self.isHidden
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
    func background(_ color: UIColor?) -> StackView {
        let backgroundModifier = StackBackgroundColorModifier(backgroundColor: color)
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
    
    @discardableResult
    func shadow(color: UIColor = UIColor(white: 0, alpha: 0.33), radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> StackView {
        let shadowModifier = ShadowModifier(color: color, radius: radius, x: x, y: y)
        return shadowModifier.modify(self)
    }
    
    @discardableResult
    func hidden() -> StackView {
        let modifier = HiddenModifier(isHidden: true)
        return modifier.modify(self)
    }
    
    @discardableResult
    func isHidden(_ isHidden: Bool) -> StackView {
        let modifier = HiddenModifier(isHidden: isHidden)
        return modifier.modify(self)
    }
}


public extension StackList {
    
    @discardableResult
    func didSelectItemAt(_ didSelectItemAt: ((StackCollectionView, IndexPath) -> ())?) -> StackList {
        self.collectionView.didSelectItemAt = didSelectItemAt
        return self
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func contentInsetAdjustmentBehavior(_ contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior) -> StackList {
        self.collectionView.collectionView.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
        return self
    }
}

public extension StackCollectionView {
    
    func reload(@StackScrollBuilder _ content: () -> StackView) {
        self.stackSubviews = (content().body as? UIStackView)?.arrangedSubviews ?? []
    }
    
    func reload<T>(@StackScrollBuilder _ children: () -> T) where T: StackView {
        self.stackSubviews = (children().body as? UIStackView)?.arrangedSubviews ?? []
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

private class BackgroundView: UIView {}

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

extension UIOffset {
    var size: CGSize {
        return CGSize(width: self.horizontal, height: self.vertical)
    }
}


extension UIColor {

    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red: red, green: green, blue: blue, alpha: alpha)
    }

    var redComponent: CGFloat {
        var red: CGFloat = 0.0
        getRed(&red, green: nil, blue: nil, alpha: nil)

        return red
    }

    var greenComponent: CGFloat {
        var green: CGFloat = 0.0
        getRed(nil, green: &green, blue: nil, alpha: nil)

        return green
    }

    var blueComponent: CGFloat {
        var blue: CGFloat = 0.0
        getRed(nil, green: nil, blue: &blue, alpha: nil)

        return blue
    }

    var alphaComponent: CGFloat {
        var alpha: CGFloat = 0.0
        getRed(nil, green: nil, blue: nil, alpha: &alpha)

        return alpha
    }
}

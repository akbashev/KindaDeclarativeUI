//
//  StackView.swift
//  KindaDeclarativeUI
//
//  Created by Jaleel Akbashev on 16.07.20.
//

import UIKit

@MainActor
public protocol StackView {
    typealias Update = (UIView) -> ()
    
    var body: UIView { get }
    
    var infiniteWidth: Bool { get set }
    var infiniteHeight: Bool { get set }
    
    func update()
}

extension UIView: StackView {
    public var body: UIView { return self }
}

@MainActor
private struct StackViewAssociationKey {
    static var infiniteWidth: [UIView: Bool] = [:]
    static var infiniteHeight: [UIView: Bool] = [:]
}

public extension StackView {
    var infiniteWidth: Bool {
        get { return StackViewAssociationKey.infiniteWidth[self.body] ?? false }
        set { StackViewAssociationKey.infiniteWidth[self.body] = newValue }
    }
    var infiniteHeight: Bool {
        get { return StackViewAssociationKey.infiniteHeight[self.body] ?? false }
        set { StackViewAssociationKey.infiniteHeight[self.body] = newValue }
    }
    
    func update() {}
}

public extension StackView {
    
    @discardableResult
    func add(to view: UIView, insets: UIEdgeInsets = .zero) -> StackView {
        if let horizontalStack = self as? HorizontalStack {
            horizontalStack.add(to: view, insets: insets)
            return view
        }
        if let verticalStack = self as? VerticalStack {
            verticalStack.add(to: view, insets: insets)
            return view
        }
        view.addSubview(self.body)
        self.body.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.body.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            self.body.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            self.body.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
            self.body.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
        ])
        return view
    }
    
    @discardableResult
    func reference<T: StackView>(to view: inout T?) -> StackView {
        view = self.body as? T
        return self
    }
    
    @discardableResult
    func reference<T: StackView>(to view: inout T) -> StackView {
        view = self.body as! T
        return self
    }
}

extension NSLayoutConstraint {
    internal func with(priority p: UILayoutPriority) -> NSLayoutConstraint {
        priority = p
        return self
    }
}

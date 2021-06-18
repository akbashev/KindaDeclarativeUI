//
//  FlatStack.swift
//  KindaDeclarativeUI
//
//  Created by Jaleel Akbashev on 22.07.20.
//  Copyright © 2020 Jaleel Akbashev. All rights reserved.
//

import UIKit

public struct FlatStack: StackView {
    
    public enum Alignment {
        case bottom, center, leading, trailing, top, leadingTop, leadingBottom, trailingTop, trailingBottom
    }
    
    public var body: UIView
    
    public var arrangedSubviews: [UIView] {
        return self.body.subviews
    }
    
    init(alignment: FlatStack.Alignment = .center,
         view: StackView) {
        (view.body as? FlatStackView)?.alignment = alignment
        self.body = view.body
    }
}

class FlatStackView: UIView {
    
    private var _constraints: [NSLayoutConstraint] = []
    var alignment: FlatStack.Alignment = .center
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        setNeedsUpdateConstraints()
    }

    override func updateConstraints() {
        super.updateConstraints()

        NSLayoutConstraint.deactivate(_constraints)
        
        self.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            _constraints.append(contentsOf: self.constraints(for: $0))
        }
        
        NSLayoutConstraint.activate(_constraints)
    }
    
    private func constraints(for subview: UIView) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if subview.infiniteWidth {
            constraints.append(
                subview.widthAnchor.constraint(equalTo: layoutMarginsGuide.widthAnchor)
            )
        } else {
            constraints.append(
                subview.widthAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.widthAnchor)
            )
        }
        if subview.infiniteHeight {
            constraints.append(
                subview.heightAnchor.constraint(equalTo: layoutMarginsGuide.heightAnchor)
            )
        } else {
            constraints.append(
                subview.heightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.heightAnchor)
            )
        }
        
        switch self.alignment {
        case .center:
            constraints.append(contentsOf: [
                subview.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
                subview.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            ])
        case .leading:
            constraints.append(contentsOf: [
                subview.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
                subview.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor)
            ])
        case .top:
            constraints.append(contentsOf: [
                subview.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
                subview.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            ])
        case .trailing:
            constraints.append(contentsOf: [
                subview.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
                subview.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            ])
        case .bottom:
            constraints.append(contentsOf: [
                subview.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
                subview.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
            ])
        case .leadingTop:
            constraints.append(contentsOf: [
                subview.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
                subview.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            ])
        case .leadingBottom:
            constraints.append(contentsOf: [
                subview.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
                subview.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
            ])
        case .trailingTop:
            constraints.append(contentsOf: [
                subview.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
                subview.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            ])
        case .trailingBottom:
            constraints.append(contentsOf: [
                subview.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
                subview.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
            ])
        }
        return constraints
    }
}

@resultBuilder
public struct FlatStackViewBuilder {
    
    public static func buildBlock(_ views: StackView?...) -> StackView {
        var view = FlatStackView()
        view.body.layoutMargins = .zero
        views.filter { $0 as? StackSpacer == nil }.compactMap { $0?.body }.forEach {
            view.addSubview($0)
        }
        let infiniteWidthViews = views.compactMap { $0 }.filter { $0.infiniteWidth == true }
        let infiniteHeightViews = views.compactMap { $0 }.filter { $0.infiniteHeight == true }
        
        view.infiniteWidth = infiniteWidthViews.count > 0
        view.infiniteHeight = infiniteHeightViews.count > 0
        return view
    }
}


public extension FlatStack {
    init(alignment: FlatStack.Alignment = .center,
         @FlatStackViewBuilder _ content: () -> StackView) {
        self.init(alignment: alignment, view: content())
    }
    
    init<T>(alignment: FlatStack.Alignment = .center,
            @FlatStackViewBuilder _ children: () -> T) where T: StackView {
        self.init(alignment: alignment, view: FlatStackViewBuilder.buildBlock(children()))
    }
}

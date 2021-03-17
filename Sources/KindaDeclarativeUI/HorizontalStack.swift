//
//  HorizontalStack.swift
//  KindaDeclarativeUI
//
//  Created by Jaleel Akbashev on 22.07.20.
//  Copyright © 2020 Jaleel Akbashev. All rights reserved.
//

import UIKit

public struct HorizontalStack: StackView {
    
    public enum Alignment {
        case bottom, center, firstTextBaseline, lastTextBaseline, top
        
        var uiStackViewAligment: UIStackView.Alignment {
            switch self {
            case .bottom:
                return .bottom
            case .center:
                return .center
            case .firstTextBaseline:
                return .firstBaseline
            case .lastTextBaseline:
                return .lastBaseline
            case .top:
                return .top
            }
        }
    }
    
    public var body: UIView {
        return self.stackView
    }
    
    private(set) var stackView: UIStackView
    
    public var arrangedSubviews: [UIView] {
        return self.stackView.arrangedSubviews
    }
    
    init(alignment: HorizontalStack.Alignment = .center,
         spacing: CGFloat = 8.0,
         stackView: UIStackView) {
        stackView.alignment = alignment.uiStackViewAligment
        stackView.spacing = spacing
        self.stackView = stackView
    }
}

@_functionBuilder
public struct HorizontalStackViewBuilder {
    
    public static func buildBlock(_ views: StackView?...) -> UIStackView {
        let views = views.compactMap { $0 }.map { view -> StackView in
            if var view = view as? StackSpacer {
                view.axis = .horizontal
                view.body.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
                return view
            }
            if view.infiniteWidth == true {
                view.body.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
            } else {
                view.body.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
                view.body.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
            }
            return view
        }
        var stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        views.compactMap { $0 }.forEach { view in
            if let stackEachView = view.body as? StackEachView {
                stackEachView.stackViews.forEach { stackView.addArrangedSubview($0.body) }
            } else {
                stackView.addArrangedSubview(view.body)
            }
        }
        
        let infiniteWidthViews = views.filter { $0.infiniteWidth == true }.compactMap { $0 }
        let infiniteHeightViews = views.filter { $0.infiniteHeight == true }.compactMap { $0 }
        
        stackView.infiniteWidth = infiniteWidthViews.count > 0
        stackView.infiniteHeight = infiniteHeightViews.count > 0
        
        for i in 0..<infiniteWidthViews.count {
            if i == 0 {
                infiniteWidthViews[i].body.widthAnchor.constraint(equalTo: stackView.layoutMarginsGuide.widthAnchor).with(priority: .defaultLow - 1).isActive = true
            }
            if i > 0 {
                infiniteWidthViews[i].body.widthAnchor.constraint(equalTo: infiniteWidthViews[0].body.widthAnchor).isActive = true
            }
        }
        infiniteHeightViews.forEach {
            $0.body.heightAnchor.constraint(equalTo: stackView.layoutMarginsGuide.heightAnchor).isActive = true
        }
        return stackView
    }
}

public extension HorizontalStack {
    init(alignment: HorizontalStack.Alignment = .center,
         spacing: CGFloat = 8.0,
         @HorizontalStackViewBuilder _ content: () -> UIStackView) {
        self.init(alignment: alignment,
                  spacing: spacing,
                  stackView: content())
    }
    
    init<T>(alignment: HorizontalStack.Alignment = .center,
            spacing: CGFloat = 8.0,
            @HorizontalStackViewBuilder _ children: () -> T) where T: StackView {
        self.init(alignment: alignment,
                  spacing: spacing,
                  stackView: HorizontalStackViewBuilder.buildBlock(children()))
    }
}


extension HorizontalStack {
    
    func add(to view: UIView, insets: UIEdgeInsets = .zero) {
        view.addSubview(self.body)
        self.body.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.body.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top).with(priority: .required - 1),
            self.body.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom).with(priority: .required - 1),
            self.body.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        if self.infiniteWidth {
            NSLayoutConstraint.activate([
                self.body.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(insets.left + insets.right))
            ])
        } else {
            NSLayoutConstraint.activate([
                self.body.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: insets.left),
                self.body.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -insets.right).with(priority: .required - 1),
            ])
        }
    }
}

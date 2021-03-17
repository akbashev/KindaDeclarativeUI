//
//  VerticalStack.swift
//  KindaDeclarativeUI
//
//  Created by Jaleel Akbashev on 22.07.20.
//  Copyright © 2020 Jaleel Akbashev. All rights reserved.
//

import UIKit

public struct VerticalStack: StackView {
    
    public enum Alignment {
        case center, leading, trailing
        
        var uiStackViewAligment: UIStackView.Alignment {
            switch self {
            case .center:
                return .center
            case .leading:
                return .leading
            case .trailing:
                return .trailing
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
    
    init(alignment: VerticalStack.Alignment = .center,
         spacing: CGFloat = 8.0,
         stackView: UIStackView) {
        stackView.alignment = alignment.uiStackViewAligment
        stackView.spacing = spacing
        self.stackView = stackView
    }
}

@_functionBuilder
public struct VerticalStackViewBuilder {
    
    public static func buildBlock(_ views: StackView?...) -> UIStackView {
        let views = views.compactMap { $0 }.map { view -> StackView in
            if var view = view as? StackSpacer {
                view.axis = .vertical
                view.body.setContentCompressionResistancePriority(.defaultLow - 1, for: .vertical)
                return view
            }
            if view.infiniteHeight == true {
                view.body.setContentCompressionResistancePriority(.defaultLow - 1, for: .vertical)
            } else {
                view.body.setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
                view.body.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
            }
            return view
        }
        var stackView = UIStackView()
        stackView.axis = .vertical
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
        
        infiniteWidthViews.forEach {
            $0.body.widthAnchor.constraint(equalTo: stackView.layoutMarginsGuide.widthAnchor).isActive = true
        }
        for i in 0..<infiniteHeightViews.count {
            if i == 0 {
                infiniteHeightViews[i].body.heightAnchor.constraint(equalTo: stackView.layoutMarginsGuide.heightAnchor).with(priority: .defaultLow - 1).isActive = true
            }
            if i > 0 {
                infiniteHeightViews[i].body.heightAnchor.constraint(equalTo: infiniteHeightViews[0].body.heightAnchor).isActive = true
            }
        }
        return stackView
    }
}

public extension VerticalStack {
    init(alignment: VerticalStack.Alignment = .center,
         spacing: CGFloat = 8.0,
         @VerticalStackViewBuilder _ content: () -> UIStackView) {
        self.init(alignment: alignment,
                  spacing: spacing,
                  stackView: content())
    }
    
    init<T>(alignment: VerticalStack.Alignment = .center,
            spacing: CGFloat = 8.0,
            @VerticalStackViewBuilder _ children: () -> T) where T: StackView {
        self.init(alignment: alignment,
                  spacing: spacing,
                  stackView: VerticalStackViewBuilder.buildBlock(children()))
    }
}

extension VerticalStack {
    
    func add(to view: UIView, insets: UIEdgeInsets = .zero) {
        view.addSubview(self.body)
        self.body.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.body.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left).with(priority: .required - 1),
            self.body.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right).with(priority: .required - 1),
            
            self.body.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        if self.infiniteHeight {
            NSLayoutConstraint.activate([
                self.body.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -(insets.top + insets.bottom))
            ])
        } else {
            NSLayoutConstraint.activate([
                self.body.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: insets.top).with(priority: .required - 1),
                self.body.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -insets.bottom).with(priority: .required - 1)
            ])
        }
        
    }
}

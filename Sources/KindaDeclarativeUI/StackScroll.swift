//
//  StackScroll.swift
//  KindaDeclarativeUI
//
//  Created by Jaleel Akbashev on 22.07.20.
//  Copyright © 2020 Jaleel Akbashev. All rights reserved.
//

import UIKit

public struct StackScroll: StackView {
    
    public struct Axis: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let vertical = Axis(rawValue:1)
        public static let horizontal = Axis(rawValue:2)
        
        public static let all: Axis = [.vertical, .horizontal]
        
        var uiStackViewAxis: NSLayoutConstraint.Axis {
            switch self {
            case .horizontal:
                return .horizontal
            default:
                return .vertical
            }
        }
    }
    
    public var body: UIView {
        return self.scrollView
    }
    
    public var scrollView: UIScrollView
    
    public init(axis: StackScroll.Axis = .vertical,
                showsIndicators: Bool = true,
                stackView: StackView) {
        if let uiStackView = stackView.body as? UIStackView {
            uiStackView.axis = axis.uiStackViewAxis
            uiStackView
                .getSubviewsOf(StackSpacerView.self)
                .forEach { $0.removeFromSuperview() }
        }
        self.scrollView = UIScrollView()
        let view = stackView.body
        self.scrollView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
        ])
        switch axis {
        case .horizontal:
            view.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
        case .vertical:
            view.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
        default:
            break
        }
        self.scrollView.showsHorizontalScrollIndicator = showsIndicators
        self.scrollView.showsVerticalScrollIndicator = showsIndicators
    }
}

@_functionBuilder
public struct StackScrollBuilder {
    
    public static func buildBlock(_ views: StackView?...) -> StackView {
        func checkIfStackView(_ views: [StackView]) -> StackView? {
            guard views.count == 1 else {
                return nil
            }
            return views.first as? VerticalStack ?? views.first as? HorizontalStack
        }
        
        func checkIfForEach(_ views: [StackView]) -> StackEachView? {
            guard views.count == 1 else {
                return nil
            }
            return views.first?.body as? StackEachView
        }
        
        let views = views.compactMap { $0 }
        if let view = checkIfStackView(views) {
            return view
        }

        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true

        let subviews = checkIfForEach(views)?.stackViews.map { $0.body } ?? views.compactMap { $0.body }
        subviews.forEach { stackView.addArrangedSubview($0) }
        return stackView
    }
}

public extension StackScroll {
    
    init(axis: StackScroll.Axis = .vertical,
         showsIndicators: Bool = true,
         @StackScrollBuilder _ content: () -> StackView) {
        self.init(axis: axis,
                  showsIndicators: showsIndicators,
                  stackView: content())
    }
    
    init<T>(axis: StackScroll.Axis = .vertical,
            showsIndicators: Bool = true,
            @StackScrollBuilder _ children: () -> T) where T: StackView {
        self.init(axis: axis,
                  showsIndicators: showsIndicators,
                  stackView: children())
    }
    
}


private extension UIStackView {
    func getSubviewsOf<T: UIView>(_ type: T.Type) -> [T] {
        func shouldGoDeeper(for subStackView: UIStackView) -> Bool {
            return subStackView.axis == self.axis
        }
        var subviews = [T]()
        self.arrangedSubviews.forEach { subview in
            if let subStackView = subview as? UIStackView,
               shouldGoDeeper(for: subStackView) {
                subviews += subStackView.getSubviewsOf(type) as [T]
            }
            if let subview = subview as? T {
                subviews.append(subview)
            }
        }
        return subviews
    }
}

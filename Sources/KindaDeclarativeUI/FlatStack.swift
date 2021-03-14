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

private class FlatStackView: UIView {
    
    var alignment: FlatStack.Alignment = .center {
        didSet {
            self.layoutIfNeeded()
        }
    }
    
  override var intrinsicContentSize: CGSize {
    let sizes = self.subviews.map { view -> CGSize in
      let width: CGFloat = self.subviewWidth[view] ?? view.intrinsicContentSize.width
      let height: CGFloat = self.subviewHeight[view] ?? view.intrinsicContentSize.height
      return CGSize(width: width, height: height)
    }
    let width = sizes.map { $0.width }.sorted().last ?? 0.0
    let height = sizes.map { $0.height }.sorted().last ?? 0.0
    return CGSize(width: width + self.layoutMargins.left + self.layoutMargins.right,
                  height: height + self.layoutMargins.top + self.layoutMargins.bottom)
  }
  
    var subviewWidth: [UIView:CGFloat] = [:]
    var subviewHeight: [UIView:CGFloat] = [:]

    override func layoutSubviews() {
        super.layoutSubviews()
        let viewWidth = self.bounds.width - self.layoutMargins.left - self.layoutMargins.right
        let viewHeight = self.bounds.height - self.layoutMargins.top - self.layoutMargins.bottom
        self.subviews.forEach { view in
          
          if view.infiniteWidth {
            self.subviewWidth[view] = viewWidth
          }
          
          if view.infiniteHeight {
            self.subviewHeight[view] = viewHeight
          }
          
          let width: CGFloat = self.subviewWidth[view] ?? view.intrinsicContentSize.width
          let height: CGFloat = self.subviewHeight[view] ?? view.intrinsicContentSize.height

            let x: CGFloat
            let y: CGFloat

            switch self.alignment {
            case .center:
                x = self.layoutMargins.left + (viewWidth - width) / 2
                y = self.layoutMargins.top + (viewHeight - height) / 2
            case .leading:
                x = self.layoutMargins.left
                y = self.layoutMargins.top + (viewHeight - height) / 2
            case .top:
                x = self.layoutMargins.left + (viewWidth - width) / 2
                y = self.layoutMargins.top
            case .trailing:
                x = self.layoutMargins.left + viewWidth - width
                y = self.layoutMargins.top + (viewHeight - height) / 2
            case .bottom:
                x = self.layoutMargins.left + (viewWidth - width) / 2
                y = self.layoutMargins.top + viewHeight - height
            case .leadingTop:
              x = self.layoutMargins.left
              y = self.layoutMargins.top
            case .leadingBottom:
              x = self.layoutMargins.left
              y = self.layoutMargins.top + viewHeight - height
            case .trailingTop:
              x = self.layoutMargins.left + viewWidth - width
              y = self.layoutMargins.top
            case .trailingBottom:
              x = self.layoutMargins.left + viewWidth - width
              y = self.layoutMargins.top + viewHeight - height
            }
            view.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
}

@_functionBuilder
public struct FlatStackViewBuilder {
    
    public static func buildBlock(_ views: StackView?...) -> StackView {
        var view = FlatStackView()
        view.body.layoutMargins = .zero
        views.filter { $0 as? StackSpacer == nil }.compactMap { $0?.body }.forEach {
            // We need to remove widthAnchor and heightAnchor constant constraints first,
            if let widthAnchorConstraint = $0.widthAnchorConstraint {
              view.subviewWidth[$0] = widthAnchorConstraint.constant
              widthAnchorConstraint.isActive = false
            }
            if let heightAnchorConstraint = $0.heightAnchorConstraint {
              view.subviewHeight[$0] = heightAnchorConstraint.constant
              heightAnchorConstraint.isActive = false
            }
            // and then add those views.
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

//
//  StackView.swift
//  KindaDeclarativeUI
//
//  Created by Jaleel Akbashev on 16.07.20.
//

import UIKit

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
    public func with(priority p: UILayoutPriority) -> NSLayoutConstraint {
        priority = p
        return self
    }
}

// EXPERIMENTAL
#if canImport(SwiftUI)
import SwiftUI

public struct UIViewWrapper<View: UIView>: UIViewRepresentable {
    public typealias Maker = () -> View
    public typealias Updater = (View, Context) -> ()
    
    var makeView: Maker
    var updateView: Updater?
    
    public init(_ makeView: @escaping Maker,
                updateView: Updater? = nil) {
        self.makeView = makeView
        self.updateView = updateView
    }
    
    public func makeUIView(context: Context) -> View {
        makeView()
    }
    
    public func updateUIView(_ view: View, context: Context) {
        updateView?(view, context)
    }
}

@available(iOS 13.0, *)
public extension UIView {
    var swiftUIView: some View {
        return UIViewWrapper {
            return self
        }
    }
    
    func swiftUIView(_ updateView: ((UIView) -> ())? = nil) -> some View {
        return UIViewWrapper ({
            self
        }, updateView: { _,_  in
            updateView?(self)
        })
    }
}

@available(iOS 13.0, *)
public extension StackView {
    
    var swiftUIView: some View {
        ContentView(view: self)
    }
}
//    func swiftUIView(_ updateView: UIViewWrapper<UIView>.Updater? = nil) -> some View {
//        return UIViewWrapper ({
//            self.bodyx
//        }, updateView: { view, context in
//            updateView?(view, context)
//        })
//    }
//}


@available(iOS 13.0, *)
private struct ContentView: View {
    
    @State var frame: CGSize = .zero
    
    private let view: StackView
    
    init(view: StackView) {
        self.view = view
    }
    
    var body: some View {
        GeometryReader { (geometry) in
            self.makeView(geometry)
        }
    }
    
    func makeView(_ geometry: GeometryProxy) -> some View {
        let targetSize = CGSize(width: self.view.infiniteWidth ? geometry.size.width : UIView.layoutFittingCompressedSize.width, height: self.view.infiniteHeight ? geometry.size.height : UIView.layoutFittingCompressedSize.height)
        let horizontalFittingPriority: UILayoutPriority = self.view.infiniteWidth ? .required : .fittingSizeLevel
        let verticalFittingPriority: UILayoutPriority = self.view.infiniteHeight ? .required : .fittingSizeLevel
        let calculatedSize = self.view.body.systemLayoutSizeFitting(targetSize,
                                                          withHorizontalFittingPriority: horizontalFittingPriority,
                                                          verticalFittingPriority: verticalFittingPriority)
        DispatchQueue.main.async { self.frame = CGSize(width: max(geometry.size.width, calculatedSize.width), height: max(geometry.size.height, calculatedSize.height)) }
        return UIViewWrapper {
            return self.view.body
        }.frame(width: frame.width,
                height: frame.height, alignment: .center)
    }
}

#endif

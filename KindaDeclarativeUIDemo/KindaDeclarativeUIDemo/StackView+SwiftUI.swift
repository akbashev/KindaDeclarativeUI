//
//  StackView+SwiftUI.swift
//  
//
//  Created by Jaleel Akbashev on 15.04.21.
//

// EXPERIMENTAL
import SwiftUI
import UIKit
import KindaDeclarativeUI

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

public extension StackView {
    
    var swiftUIView: some View {
        StackViewContentView(view: self)
    }
}


private struct StackViewContentView: View {
    
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


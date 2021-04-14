//
//  StackView+SwiftUI.swift
//  
//
//  Created by Jaleel Akbashev on 15.04.21.
//

// EXPERIMENTAL

#if canImport(SwiftUI)
import SwiftUI
import UIKit

@available(iOS 13.0, *)
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

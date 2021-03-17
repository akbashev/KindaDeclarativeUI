//
//  StackEach.swift
//  
//
//  Created by Jaleel Akbashev on 14.03.21.
//

import UIKit

public struct StackEach<Data, ID, Content>: StackView where Data: RandomAccessCollection, ID: Hashable {
    public var body: UIView {
        return self.stackEachView
    }
    
    public var stackViews: [StackView] {
        return self.stackEachView.stackViews
    }
    
    private let stackEachView: StackEachView
}

class StackEachView: UIView {
    var stackViews: [StackView] = []
}

extension StackEach where ID == Data.Element.ID, Content: StackView, Data.Element : Identifiable {
    public init(_ data: Data, content: @escaping (Data.Element) -> Content) {
        let view = StackEachView()
        data.forEach { item in
            view.stackViews.append(content(item))
        }
        self.stackEachView = view
    }
}
extension StackEach where Content: StackView {
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> Content) {
        let view = StackEachView()
        data.forEach { item in
            view.stackViews.append(content(item))
        }
        self.stackEachView = view
    }
}

extension StackEach where Data == Range<Int>, ID == Int, Content: StackView {
    public init(_ data: Range<Int>, content: @escaping (Int) -> Content) {
        let view = StackEachView()
        data.forEach { item in
            view.stackViews.append(content(item))
        }
        self.stackEachView = view
    }
}

public protocol Identifiable {
    
    /// A type representing the stable identity of the entity associated with `self`.
    associatedtype ID: Hashable
    
    /// The stable identity of the entity associated with `self`.
    var id: ID { get }
}

public extension Identifiable where Self: AnyObject {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

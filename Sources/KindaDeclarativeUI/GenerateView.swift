import UIKit

public protocol MappedView {}

public extension MappedView where Self: UIView {
    @MainActor
    func map(_ closure: @MainActor (Self) throws -> Void) rethrows -> Self {
        try closure(self)
        return self
    }
}

extension UIView: MappedView {}

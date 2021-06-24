//
//  StackList.swift
//  
//
//  Created by Jaleel Akbashev on 14.03.21.
//

import UIKit

public struct StackList: StackView {
    
    public struct Axis: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let vertical = Axis(rawValue:1)
        public static let horizontal = Axis(rawValue:2)
        
        public static let all: Axis = [.vertical, .horizontal]
        
        var uiStackViewAxis: UICollectionView.ScrollDirection {
            switch self {
            case .horizontal:
                return .horizontal
            default:
                return .vertical
            }
        }
    }
    
    public var body: UIView {
        return self.collectionView
    }
    
    var collectionView: StackCollectionView
    
    public init(axis: StackList.Axis = .vertical,
                spacing: CGFloat = 8.0,
                stackView: StackView) {
        self.collectionView = StackCollectionView(stackSubviews: (stackView.body as? UIStackView)?.arrangedSubviews ?? [], axis: axis, spacing: spacing)
    }
}

public class StackCollectionView: UIView {
    
    public var stackSubviews: [StackView]
    
    public func insert(_ items: [StackView]) {
        self.stackSubviews.append(contentsOf: items)
        self.collectionView.reloadData()
    }
    
    public func insert(_ item: StackView, at index: Int) {
        self.collectionView.performBatchUpdates({
            self.stackSubviews.insert(item, at: index)
        }, completion: {_ in
            UIView.animate(withDuration: 0.25, animations: {
                self.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
            })
        })
    }
    
    public func remove(at index: Int) {
        self.collectionView.performBatchUpdates({
            self.stackSubviews.remove(at: index)
        }, completion: {_ in
            UIView.animate(withDuration: 0.25, animations: {
                self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            })
        })
    }
    
    public func removeAll() {
        self.stackSubviews.removeAll()
        self.collectionView.reloadData()
    }
    
    public let axis: StackList.Axis
    public let spacing: CGFloat
    
    public var didSelectItemAt: ((StackCollectionView, IndexPath) -> ())?
    
    var showContent: Bool {
        self.stackSubviews.count > 0
    }
    
    public lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: self.bounds, collectionViewLayout: self.collectionViewLayout)
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.clipsToBounds = true
        view.allowsSelection = true
        view.allowsMultipleSelection = false
        view.register(StackCollectionViewCell.self, forCellWithReuseIdentifier: StackCollectionViewCell.identifier)
        return view
    }()
    
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = self.axis.uiStackViewAxis
        layout.headerReferenceSize = .zero
        layout.minimumLineSpacing = self.spacing
        layout.estimatedItemSize = CGSize(width: 100, height: 100)
        return layout
    }()
    
    init(stackSubviews: [StackView] = [], axis: StackList.Axis, spacing: CGFloat) {
        self.axis = axis
        self.spacing = spacing
        self.stackSubviews = stackSubviews
        super.init(frame: .zero)
        self.addSubview(self.collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = self.bounds
        switch self.axis {
        case .horizontal:
            self.collectionViewLayout.estimatedItemSize = CGSize(width: 100, height: self.collectionView.widestCellHeight)
        default:
            self.collectionViewLayout.estimatedItemSize = CGSize(width: self.collectionView.widestCellWidth, height: 100)
        }
        self.stackSubviews.forEach { stackView in
            if stackView.infiniteWidth {
                stackView.body.frame = CGRect(origin: .zero, size: CGSize(width: self.bounds.width, height: 0))
            }
            if stackView.infiniteHeight {
                stackView.body.frame = CGRect(origin: .zero, size: CGSize(width: 0, height: self.bounds.height))
            }
        }
    }
}

extension StackCollectionView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard collectionView.bounds != .zero else { return .zero }
        return self.stackSubviews.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StackCollectionViewCell.identifier, for: indexPath) as! StackCollectionViewCell
        let stackView = self.stackSubviews[indexPath.item]
        cell.axis = self.axis
        cell.view = stackView.body
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didSelectItemAt?(self, indexPath)
    }
}

class StackCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "StackCollectionViewCell"
    
    var axis: StackList.Axis = .vertical
    var view: UIView? {
        set {
            self.view?.removeFromSuperview()
            if let view = newValue {
                view.add(to: self.contentView)
            }
        }
        get {
            self.contentView.subviews.first
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.view = nil
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        if view?.body is FlatStackView {
            let width: CGFloat = view?.infiniteWidth == true ? targetSize.width : 0
            let height: CGFloat = view?.infiniteHeight == true ? targetSize.height : 0
            return self.view?.body.systemLayoutSizeFitting(CGSize(width: width, height: height), withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .fittingSizeLevel) ?? .zero
        }
        switch axis {
        case .horizontal:
            let verticalFittingPriority: UILayoutPriority = view?.infiniteHeight == true ? .required : .fittingSizeLevel
            return self.view?.body.systemLayoutSizeFitting(CGSize(width: 0, height: targetSize.height), withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: verticalFittingPriority) ?? .zero
        default:
            let horizontalFittingPriority: UILayoutPriority = view?.infiniteWidth == true ? .required : .fittingSizeLevel
            return self.view?.body.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 0), withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: .fittingSizeLevel) ?? .zero
        }
        
    }
}

public extension StackList {
    
    init(
        axis: StackList.Axis = .vertical,
        spacing: CGFloat = 8.0,
        @StackScrollBuilder _ content: () -> StackView
    ) {
        self.init(
            axis: axis,
            spacing: spacing,
            stackView: content()
        )
    }
    
    init<T>(
        axis: StackList.Axis = .vertical,
        spacing: CGFloat = 8.0,
        @StackScrollBuilder _ children: () -> T
    ) where T: StackView {
        self.init(
            axis: axis,
            spacing: spacing,
            stackView: children()
        )
    }
    
}

extension UICollectionView {
    var widestCellWidth: CGFloat {
        let insets = contentInset.left + contentInset.right
        return max(0, bounds.width - insets)
    }
    
    var widestCellHeight: CGFloat {
        let insets = contentInset.top + contentInset.bottom
        return max(0, bounds.height - insets)
    }
}

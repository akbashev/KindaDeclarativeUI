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
                stackView: StackView) {
        self.collectionView = StackCollectionView(stackSubviews: (stackView.body as? UIStackView)?.arrangedSubviews ?? [], axis: axis)
    }
}

class StackCollectionView: UIView {
    
    let stackSubviews: [StackView]
    let axis: StackList.Axis
    
    var showContent: Bool {
        self.stackSubviews.count > 0
    }
    
    lazy var collectionView: UICollectionView = {
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
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: 100, height: 100)
        return layout
    }()
    
    init(stackSubviews: [StackView] = [], axis: StackList.Axis) {
        self.axis = axis
        self.stackSubviews = stackSubviews
        super.init(frame: .zero)
        self.addSubview(self.collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard collectionView.bounds != .zero else { return .zero }
        return self.stackSubviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StackCollectionViewCell.identifier, for: indexPath) as! StackCollectionViewCell
        let stackView = self.stackSubviews[indexPath.item]
        cell.view = stackView
        cell.axis = self.axis
        return cell
    }
}

class StackCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "StackCollectionViewCell"
    
    var axis: StackList.Axis = .vertical
    var view: StackView? {
        didSet {
            oldValue?.body.removeFromSuperview()
            if let view = self.view {
                view.add(to: self.contentView)
            }
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
    
    init(axis: StackList.Axis = .vertical,
         @StackScrollBuilder _ content: () -> StackView) {
        self.init(axis: axis, stackView: content())
    }
    
    init<T>(axis: StackList.Axis = .vertical,
            @StackScrollBuilder _ children: () -> T) where T: StackView {
        self.init(axis: axis, stackView: children())
    }
    
}

extension UICollectionView {
    var widestCellWidth: CGFloat {
        let insets = contentInset.left + contentInset.right
        return bounds.width - insets
    }
    
    var widestCellHeight: CGFloat {
        let insets = contentInset.top + contentInset.bottom
        return bounds.height - insets
    }
}

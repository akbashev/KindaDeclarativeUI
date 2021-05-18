# KindaDeclarativeUI

An API to wrap `UIStackView` and replicate SwiftUI layout system.
It's an early stage, API was more important than code in the beggining. So first I've immitated 

```swift
  StackList {
      StackEach(viewModels, id: \.id) { viewModel in
          VerticalStack(spacing: 0) {
              HorizontalStack(spacing: 8) {
                  UILabel().map {
                      $0.text = viewModel.leftString
                      $0.textColor = UIView.mainTextColor
                      $0.font = UIFont.preferredFont(forTextStyle: .body)
                  }
                  StackSpacer()
                  UILabel().map {
                      $0.text = viewModel.rightString
                      $0.textColor = UIView.actionColor
                      $0.font = UIFont.preferredFont(forTextStyle: .body)
                  }
                  self.someImageView
              }.padding(top: 16, left: 0, bottom: 16, right: 0)
              UIView().map {
                  $0.backgroundColor = UIColor.black
              }.frame(width: .infinity, height: 1)
          }
      }
  }.padding(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
  .add(to: self)
```

All UIKit views can bet at put into Stack as main idea is all views are inherit from `StackView` protocol. You can both define them before or just use `UIView().map` extension.

- API inspired by SwiftUI
- Views are centered by default
- Spacing automatically defined as in SwiftUI
- `isLayoutMarginsRelativeArrangement` is automatically enabled.

## What is working?

- `VerticalStack`—simillar to `VStack`
- `HorizontalStack`—simillar to `HStack`
- `FlastStack`—kinda simillar to `ZStack`
- `StackScroll`—kinda simillar to `ScrollView`
- `StackEach`—kinda simillar to `ForEach`

## Modifiers
- `frame(width, height)` You can define `.infinity` for View to take all space like in SwiftUI.
- `border(width borderWidth: CGFloat, color borderColor: UIColor, masksToBounds: Bool = false)`
- `borderWidth(_ borderWidth: CGFloat)`
- `borderColor(_ borderColor: UIColor)`
- `background(_ color: UIColor?)`
- `masksToBounds(_ masksToBounds: Bool)`
- `cornerRadius(_ cornerRadius: CGFloat)`
- `padding(top: CGFloat = 16, left: CGFloat = 16, bottom: CGFloat = 16, right: CGFloat = 16)`
- `padding(_ padding: UIEdgeInsets)`
- `padding(_ onePadding: CGFloat)`
- `debug(_ color: UIColor = .yellow)`

## Experimental
- StackList—just a wrapper arround UICollectionView, so it doesn't match SwiftUI's List.

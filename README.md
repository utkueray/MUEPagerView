# MUPager

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.0+

## Installation

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

To integrate MUPager into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/utkueray/MUPager", .upToNextMajor(from: "0.1.0"))
]
```

## Usage

### Quick Start

```swift
import MUPager

lazy var pager: MUPagerView = {
    let pager = MUPagerView()
    pager.menuDeselectedColor = .darkGray
    pager.menuSelectedColor = .white
    pager.menuIndicatorColor = .orange
    pager.dataSource = self
    return pager
}()

// MARK: MUPagerViewDataSource
func pagerViewStartingIndex(_ pager: MUPager.MUPagerView) -> Int {
    return 0
}
    
func pagerViewMenuItems(_ pager: MUPager.MUPagerView) -> [MUPager.MUMenuItem] {
    return menuItems
}

func pager(_ pager: MUPager.MUPagerView, pageForIndexPathAt indexPath: IndexPath) -> UIView {
    let view = UIView()
    view.backgroundColor = pageColors[indexPath.item]
    return view
}
```
## Credits

- Utku Eray ([@utkueray](https://github.com/utkueray))

## License

MUPager is released under the MIT license. See LICENSE for details.

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

class ViewController: UIViewController {

    lazy var view1: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    lazy var view2: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    lazy var view3: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()

    lazy var pagerView: MUPager = {
        let view = MUPager()
        view.menuDeselectedColor = .gray
        view.menuSelectedColor = .white
        view.menuUnderLineColor = .orange
        view.delegate = self
        view.dataSource = self
        return view
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
        pagerView.reload()
    }
}
// MARK: MUPagerDataSource
extension ViewController: MUPagerDataSource {
    func pagerViewTitles(_ pager: MUPager) -> [String] {
        return ["View1", "View2", "View3"]
    }
    
    func pagerViewStartingIndex(_ pager: MUPager) -> Int {
        return 0
    }
    
    func pager(_ pager: MUPager, pageForIndexPathAt indexPath: IndexPath) -> UIView {
        let pages = [view1, view2, view3]
        return pages[indexPath.item]
    }
}

// MARK: MUPagerDelegate
extension ViewController: MUPagerDelegate {
    public func pagerView(_ pager: MUPager, willDisplay page: UIView, forItemAt indexPath: IndexPath) {
        print("Page:", indexPath)
    }
    
    func pagerView(_ pager: MUPager, didEndDisplaying page: UIView, forItemAt indexPath: IndexPath) {
        
    }
}
```
## Credits

- Utku Eray ([@utkueray](https://github.com/utkueray))

## License

MUPager is released under the MIT license. See LICENSE for details.

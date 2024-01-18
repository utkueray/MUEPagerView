# MUEPagerView

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.0+

## Installation

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

To integrate MUEPagerView into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/utkueray/MUEPagerView", .upToNextMajor(from: "0.1.0"))
]
```

## Usage

### Quick Start

```swift
import MUEPagerView

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

    lazy var pagerView: MUEPagerView = {
        let view = MUEPagerView()
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
// MARK: MUEPagerViewDataSource
extension ViewController: MUEPagerViewDataSource {
    func pagerViewTitles(_ pager: MUEPagerView) -> [String] {
        return ["View1", "View2", "View3"]
    }
    
    func pagerViewStartingIndex(_ pager: MUEPagerView) -> Int {
        return 0
    }
    
    func pager(_ pager: MUEPagerView, pageForIndexPathAt indexPath: IndexPath) -> UIView {
        let pages = [view1, view2, view3]
        return pages[indexPath.item]
    }
}

// MARK: MUEPagerViewDelegate
extension ViewController: MUEPagerViewDelegate {
    public func pagerView(_ pager: MUEPagerView, willDisplay page: UIView, forItemAt indexPath: IndexPath) {
        print("Page:", indexPath)
    }
    
    func pagerView(_ pager: MUEPagerView, didEndDisplaying page: UIView, forItemAt indexPath: IndexPath) {
        
    }
}
```
## Credits

- Utku Eray ([@utkueray](https://github.com/utkueray))

## License

MUEPagerView is released under the MIT license. See LICENSE for details.

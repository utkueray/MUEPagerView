//
//  MUPagerView.swift
//
//
//  Created by Mehmet Utku Eray on 12.01.2024.
//

import UIKit
import SnapKit

public protocol MUPagerViewDataSource: AnyObject {
    func pagerViewStartingIndex(_ pager: MUPagerView) -> Int
    func pagerViewMenuItems(_ pager: MUPagerView) -> [MUMenuItem]
    func pager(_ pager: MUPagerView, pageForIndexPathAt indexPath: IndexPath) -> UIView
}

public protocol MUPagerViewDelegate: AnyObject {
    func pagerView(_ pager: MUPagerView, willDisplay page: UIView, forItemAt indexPath: IndexPath)
    func pagerView(_ pager: MUPagerView, didEndDisplaying page: UIView, forItemAt indexPath: IndexPath)
}

public extension MUPagerViewDelegate {
    func pagerView(_ pager: MUPagerView, willDisplay page: UIView, forItemAt indexPath: IndexPath) { }
    func pagerView(_ pager: MUPagerView, didEndDisplaying page: UIView, forItemAt indexPath: IndexPath) { }
}

public protocol MUPagerFlowLayoutDelegate: AnyObject {
    func pagerViewMenuAlignment() -> MUMenuViewAlignment
    func pagerMenuViewSpacingBetweenMenuItems(_ pager: MUPagerView) -> CGFloat
    func pagerMenuView(_ pager: MUPagerView, widthForItemAt indexPath: IndexPath) -> CGFloat
}

public final class MUPagerView: UIView {
    private var didSetConstraints: Bool = false
    private var menuItems: [MUMenuItem] = []
    private var previousIndexPath: IndexPath? = nil
    private var selectedIndexPath: IndexPath? = nil
    private var didSetInitialIndex: Bool = false
    private var disablePaging: Bool = true

    public weak var dataSource: MUPagerViewDataSource? = nil
    public weak var delegate: MUPagerViewDelegate? = nil
    public weak var flowLayoutDelegate: MUPagerFlowLayoutDelegate? = nil

    public var menuDeselectedColor: UIColor = .darkGray {
        didSet {
            menuView.deselectedColor = menuDeselectedColor
        }
    }
    
    public var menuSelectedColor: UIColor = .white {
        didSet {
            menuView.selectedColor = menuSelectedColor
        }
    }
    
    public var menuIndicatorColor: UIColor = .orange {
        didSet {
            menuView.indicatorColor = menuIndicatorColor
        }
    }
    
    public var menuViewFont: UIFont = .systemFont(ofSize: 16.0) {
        didSet {
            menuView.font = menuViewFont
        }
    }
    
    public var menuViewHasIndicator: Bool = true {
        didSet {
            menuView.hasIndicator = menuViewHasIndicator
        }
    }
    
    public var menuViewEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            menuView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(menuViewEdgeInsets.top)
                make.left.equalToSuperview().offset(menuViewEdgeInsets.left)
                make.right.equalToSuperview().offset(-menuViewEdgeInsets.right)
                make.height.equalTo(menuViewHeight)
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    public var menuViewHeight: CGFloat = 42.0 {
        didSet {
            menuView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(menuViewEdgeInsets.top)
                make.left.equalToSuperview().offset(menuViewEdgeInsets.left)
                make.right.equalToSuperview().offset(-menuViewEdgeInsets.right)
                make.height.equalTo(menuViewHeight)
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    public var pagesScrollDirection: UICollectionView.ScrollDirection = .horizontal {
        didSet {
            pagesCollectionViewFlowLayout.scrollDirection = pagesScrollDirection
        }
    }
    
    public var pagesMinimumLineSpacing: CGFloat = .zero {
        didSet {
            pagesCollectionViewFlowLayout.minimumLineSpacing = pagesMinimumLineSpacing
            pagesCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    public var pagesMinimumInteritemSpacing: CGFloat = .zero {
        didSet {
            pagesCollectionViewFlowLayout.minimumInteritemSpacing = pagesMinimumInteritemSpacing
            pagesCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    public var pageSize: CGSize = .zero {
        didSet {
            pagesCollectionViewFlowLayout.itemSize = pageSize
            pagesCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    public var pagesBackgroundColor: UIColor = .clear {
        didSet {
            pagesCollectionView.backgroundColor = pagesBackgroundColor
        }
    }
    
    public var pagesShouldBounce: Bool = true {
        didSet {
            pagesCollectionView.bounces = pagesShouldBounce
        }
    }
    
    public var showsSrollIndicators: Bool = false {
        didSet {
            pagesCollectionView.showsVerticalScrollIndicator = showsSrollIndicators
            pagesCollectionView.showsHorizontalScrollIndicator = showsSrollIndicators
        }
    }
    
    public var pagesEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0) {
        didSet {
            pagesCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(menuView.snp.bottom).offset(pagesEdgeInsets.top)
                make.left.equalToSuperview().offset(pagesEdgeInsets.left)
                make.right.equalToSuperview().offset(-pagesEdgeInsets.right)
                make.bottom.equalToSuperview().offset(-pagesEdgeInsets.bottom)
            }
        }
    }
    
    // MARK: Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        pageSize = pagesCollectionView.frame.size
    }
    
    // MARK: User Interface
    private func setupUI() {
        addSubview(menuView)
        addSubview(pagesCollectionView)
        
        setNeedsUpdateConstraints()
        updateViewConstraints()
    }
    
    private lazy var menuView: MUMenuView = {
        let view = MUMenuView()
        view.deselectedColor = menuDeselectedColor
        view.selectedColor = menuSelectedColor
        view.indicatorColor = menuIndicatorColor
        view.delegate = self
        view.dataSource = self
        view.flowLayout = self
        return view
    }()
    
    private lazy var pagesCollectionViewFlowLayout: MUCollectionFlowLayout = {
        let layout = MUCollectionFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = pagesMinimumLineSpacing
        layout.minimumInteritemSpacing = pagesMinimumInteritemSpacing
        layout.sectionInset = .zero
        return layout
    }()
    
    private lazy var pagesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: pagesCollectionViewFlowLayout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "pageCell")
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = showsSrollIndicators
        collectionView.showsHorizontalScrollIndicator = showsSrollIndicators
        collectionView.backgroundColor = pagesBackgroundColor
        collectionView.bounces = pagesShouldBounce
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.accessibilityIdentifier = "pagesCollectionView"
        return collectionView
    }()
}

// MARK: Methods
extension MUPagerView {
    public func reload() {
        if selectedIndexPath == nil {
            previousIndexPath = selectedIndexPath
            selectedIndexPath = IndexPath(item: dataSource?.pagerViewStartingIndex(self) ?? 0, section: 0)
        }
        
        menuItems = dataSource?.pagerViewMenuItems(self) ?? []
        menuView.reload()
        pagesCollectionView.reloadData()
    }
    
    public func selectIndex(_ index: Int) {
        previousIndexPath = selectedIndexPath
        selectedIndexPath = IndexPath(item: index, section: 0)
        pagesCollectionView.scrollToItem(at: selectedIndexPath!, at: .centeredHorizontally, animated: true)
        menuView.selectItem(indexPath: selectedIndexPath!)
        didSetInitialIndex = true
    }
    
    public func currentIndex() -> Int? {
        if let selectedIndexPath {
            return selectedIndexPath.item
        }
        return nil
    }
}

// MARK: MUMenuViewDataSource
extension MUPagerView: MUMenuViewDataSource {
    public func menuViewMenuItems(_ pager: MUMenuView) -> [MUMenuItem]? {
        return menuItems
    }
    
    public func menuViewStartingIndex(_ menu: MUMenuView) -> Int {
        return dataSource?.pagerViewStartingIndex(self) ?? selectedIndexPath?.item ?? 0
    }
}

// MARK: MUMenuViewDelegate
extension MUPagerView: MUMenuViewDelegate {
    public func menuView(_ menuView: MUMenuView, willDisplay menuItem: MUMenuItem, forItemAt indexPath: IndexPath) {
        
    }
    
    public func menuView(_ menuView: MUMenuView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexPath != indexPath {
            previousIndexPath = selectedIndexPath
            selectedIndexPath = indexPath
            pagesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    public func menuView(_ menuView: MUMenuView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: MUMenuViewFlowLayout
extension MUPagerView: MUMenuViewFlowLayoutDelegate {
    public func menuViewSpacingBetweenMenuItems(_ menuView: MUMenuView) -> CGFloat {
        return flowLayoutDelegate?.pagerMenuViewSpacingBetweenMenuItems(self) ?? 24.0
    }
    
    public func menuView(_ menuView: MUMenuView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let width = flowLayoutDelegate?.pagerMenuView(self, widthForItemAt: indexPath) {
            let height = menuView.frame.height
            return CGSize(width: width, height: height)
        } else if menuItems.count > 0 {
            let height = menuView.frame.height
            let menuItem = menuItems[indexPath.item]
            var stackViewWidth:CGFloat = 0.0
            
            if menuItem.hasIcon() {
                stackViewWidth += menuItem.iconSize?.width ?? 0.0
                stackViewWidth += menuItem.spacing ?? 0.0
            }
            
            stackViewWidth += menuItem.title?.width(font: menuView.font, height: height) ?? 0.0
            return CGSize(width: stackViewWidth,
                          height: height)
        } else {
            return .zero
        }
    }
    
    public func menuViewAlignment(_ menuView: MUMenuView) -> MUMenuViewAlignment {
        return flowLayoutDelegate?.pagerViewMenuAlignment() ?? .center
    }
}

// MARK: UICollectionViewDataSource
extension MUPagerView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath)
        
        for subView in cell.contentView.subviews {
            subView.removeFromSuperview()
        }
        
        if let page = dataSource?.pager(self, pageForIndexPathAt: indexPath) {
            page.frame = cell.contentView.bounds
            cell.contentView.addSubview(page)
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension MUPagerView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView,
                               willDisplay cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        if disablePaging,
        let selectedIndexPath = selectedIndexPath {
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
            return
        }
        
        if !didSetInitialIndex,
        let selectedIndexPath = selectedIndexPath {
            menuView.selectItem(indexPath: selectedIndexPath)
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
            didSetInitialIndex = true
        } else {
            previousIndexPath = selectedIndexPath
            selectedIndexPath = indexPath
            menuView.selectItem(indexPath: indexPath)
            
            if let page = cell.contentView.subviews.first,
               let delegate = delegate {
                delegate.pagerView(self, willDisplay: page, forItemAt: indexPath)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didEndDisplaying cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        if let page = cell.contentView.subviews.first,
           let delegate = delegate {
            
            if selectedIndexPath == indexPath,
               let previousIndexPath = previousIndexPath {
                selectedIndexPath = previousIndexPath
                menuView.selectItem(indexPath: previousIndexPath)
            }
            
            delegate.pagerView(self, didEndDisplaying: page, forItemAt: indexPath)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        disablePaging = false
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        disablePaging = true
    }
}

// MARK: Auto Layout
extension MUPagerView {
    private func updateViewConstraints() {
        if !didSetConstraints {
            setupConstraints()
            didSetConstraints = true
        }
    }

    private func setupConstraints() {
        menuView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(menuViewEdgeInsets.top)
            make.left.equalToSuperview().offset(menuViewEdgeInsets.left)
            make.right.equalToSuperview().offset(-menuViewEdgeInsets.right)
            make.height.equalTo(menuViewHeight)
        }
        
        pagesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(menuView.snp.bottom).offset(pagesEdgeInsets.top)
            make.left.equalToSuperview().offset(pagesEdgeInsets.left)
            make.right.equalToSuperview().offset(-pagesEdgeInsets.right)
            make.bottom.equalToSuperview().offset(-pagesEdgeInsets.bottom)
        }
    }
}

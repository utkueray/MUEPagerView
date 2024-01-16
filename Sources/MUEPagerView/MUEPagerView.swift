//
//  MUEPagerView.swift
//
//
//  Created by Mehmet Utku Eray on 12.01.2024.
//

import Foundation
import UIKit

public protocol MUEPagerViewDataSource: AnyObject {
    func pagerViewStartingIndex(_ pager: MUEPagerView) -> Int
    func pagerViewTitles(_ pager: MUEPagerView) -> [String]
    func pager(_ pager: MUEPagerView, pageForIndexPathAt indexPath: IndexPath) -> UIView
}

public extension MUEPagerViewDataSource {
    func pagerViewStartingIndex(_ pager: MUEPagerView) -> Int { return 0 }
}

public protocol MUEPagerViewDelegate: AnyObject {
    func pagerView(_ pager: MUEPagerView, willDisplay page: UIView, forItemAt indexPath: IndexPath)
    func pagerView(_ pager: MUEPagerView, didEndDisplaying page: UIView, forItemAt indexPath: IndexPath)
}

public extension MUEPagerViewDelegate {
    func pagerView(_ pager: MUEPagerView, willDisplay page: UIView, forItemAt indexPath: IndexPath) { }
    func pagerView(_ pager: MUEPagerView, didEndDisplaying page: UIView, forItemAt indexPath: IndexPath) { }
}

public class MUEPagerView: UIView {
    private var didSetConstraints: Bool = false
    private var titles: [String] = []
    private var selectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    private var lastPageOffset: CGFloat = 0.0
    private var didSetInitialIndex: Bool = false

    public weak var dataSource: MUEPagerViewDataSource? = nil
    public weak var delegate: MUEPagerViewDelegate? = nil
    public var menuDeselectedColor: UIColor = UIColor(red: 0.588, green: 0.588, blue: 0.588, alpha: 1)
    public var menuSelectedColor: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    public var menuUnderLineColor: UIColor = UIColor(red: 1, green: 0.737, blue: 0, alpha: 1)
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(menuView)
        addSubview(pagesCollectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()        
        pagesCollectionViewFlowLayout.itemSize = pagesCollectionView.frame.size
    }
    
    public lazy var menuView: MUEMenuView = {
        let view = MUEMenuView()
        view.deselectedColor = menuDeselectedColor
        view.selectedColor = menuSelectedColor
        view.underLineColor = menuUnderLineColor
        view.delegate = self
        view.dataSource = self
        view.flowLayout = self
        return view
    }()
    
    public lazy var pagesCollectionViewFlowLayout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = .zero
        layout.minimumInteritemSpacing = .zero
        layout.sectionInset = .zero
        return layout
    }()
    
    public lazy var pagesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: pagesCollectionViewFlowLayout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "pageCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.accessibilityIdentifier = "collectionView"
        return collectionView
    }()
    
}

// MARK: Methods
extension MUEPagerView {
    
    public func reload() {
        selectedIndexPath = IndexPath(item: dataSource?.pagerViewStartingIndex(self) ?? 0, section: 0)
        titles = dataSource?.pagerViewTitles(self) ?? []
        menuView.reload()
        pagesCollectionView.reloadData()
    }
}

// MARK: MUEMenuViewDataSource
extension MUEPagerView: MUEMenuViewDataSource {
    public func menuViewTitles(_ pager: MUEMenuView) -> [String] {
        return titles
    }
    
    public func menuViewStartingIndex(_ menu: MUEMenuView) -> Int {
        selectedIndexPath.item
    }
}

// MARK: MUEMenuViewDelegate
extension MUEPagerView: MUEMenuViewDelegate {
    public func menuView(_ menuView: MUEMenuView, willDisplay title: String, forItemAt indexPath: IndexPath) {
        
    }
    
    public func menuView(_ menuView: MUEMenuView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexPath != indexPath {
            self.pagesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    public func menuView(_ menuView: MUEMenuView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: MUEMenuViewFlowLayout
extension MUEPagerView: MUEMenuViewFlowLayout {
    public func menuViewMinimumSpacingBetweenItems(_ menuView: MUEMenuView) -> CGFloat {
        return menuView.frame.width * 0.0319
    }
    
    public func menuView(_ menuView: MUEMenuView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if titles.count > 0 {
            let font = UIFont(name: "Alexandria-SemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16.0)
            let height = menuView.frame.height
            let width = titles[indexPath.item].width(font: font, height: height)
            return CGSize(width: width, height: height)
        } else {
            return .zero
        }
    }
    
    public func menuViewAlignment(_ menuView: MUEMenuView) -> MUEMenuViewAlignment {
        return .center
    }
}

// MARK: UICollectionViewDataSource
extension MUEPagerView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
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
extension MUEPagerView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, 
                               willDisplay cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        if !didSetInitialIndex {
            menuView.selectItem(indexPath: selectedIndexPath)
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
            didSetInitialIndex = true
        } else {
            selectedIndexPath = indexPath
            menuView.selectItem(indexPath: indexPath)
            
            if let page = cell.contentView.subviews.first,
               let delegate = delegate {
                delegate.pagerView(self, willDisplay: page, forItemAt: indexPath)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let page = cell.contentView.subviews.first,
           let delegate = delegate {
            delegate.pagerView(self, didEndDisplaying: page, forItemAt: indexPath)
        }
    }
}

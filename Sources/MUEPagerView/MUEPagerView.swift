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
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(pagerMenuView)
        addSubview(collectionView)
        
        let offsetFromSides = frame.width * 0.0246
        let pagerMenuViewWidth = frame.width - (2 * offsetFromSides)
        let pagerMenuViewHeight = frame.height * 0.1167
        pagerMenuView.frame = CGRect(x: offsetFromSides, y: 0, width: pagerMenuViewWidth, height: pagerMenuViewHeight)
        collectionView.frame = CGRect(x: 0, y: pagerMenuViewHeight, width: frame.width, height: frame.height - pagerMenuViewHeight)
    }
    
    public lazy var pagerMenuView: MUEMenuView = {
        let view = MUEMenuView()
        view.deselectedColor = menuDeselectedColor
        view.selectedColor = menuSelectedColor
        view.underLineColor = menuUnderLineColor
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = .zero
        layout.minimumInteritemSpacing = .zero
        layout.sectionInset = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
        pagerMenuView.reload()
        collectionView.reloadData()
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
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    public func menuView(_ menuView: MUEMenuView, didDeselectItemAt indexPath: IndexPath) {
        
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
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !didSetInitialIndex {
            pagerMenuView.selectItem(indexPath: selectedIndexPath)
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
            didSetInitialIndex = true
        } else {
            selectedIndexPath = indexPath
            pagerMenuView.selectItem(indexPath: indexPath)
            
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

// MARK: UICollectionViewDelegateFlowLayout
extension MUEPagerView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: collectionView.frame.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
}

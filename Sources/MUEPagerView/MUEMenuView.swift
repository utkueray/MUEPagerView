//
//  MUEMenuView.swift
//
//
//  Created by Mehmet Utku Eray on 12.01.2024.
//

import Foundation
import UIKit

public protocol MUEMenuViewDataSource: AnyObject {
    func menuViewTitles(_ pager: MUEMenuView) -> [String]
    func menuViewStartingIndex(_ menu: MUEMenuView) -> Int
}

public protocol MUEMenuViewDelegate: AnyObject {
    func menuView(_ menuView: MUEMenuView, willDisplay title: String, forItemAt indexPath: IndexPath)
    func menuView(_ menuView: MUEMenuView, didSelectItemAt indexPath: IndexPath)
    func menuView(_ menuView: MUEMenuView, didDeselectItemAt indexPath: IndexPath)
}

extension MUEMenuViewDelegate {
    func menuView(_ menuView: MUEMenuView, willDisplay title: String, forItemAt indexPath: IndexPath) { }
    func menuView(_ menuView: MUEMenuView, didDeselectItemAt indexPath: IndexPath) { }
}

public class MUEMenuView: UIView {
    private var didSetConstraints: Bool = false
    private var selectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    private var titles: [String] = []
    private var didSetInitialIndex: Bool = false
    
    public weak var dataSource: MUEMenuViewDataSource? = nil
    public weak var delegate: MUEMenuViewDelegate? = nil
    public var deselectedColor: UIColor = UIColor(red: 0.588, green: 0.588, blue: 0.588, alpha: 1)
    public var selectedColor: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    public var underLineColor: UIColor = UIColor(red: 1, green: 0.737, blue: 0, alpha: 1)
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(menuCollectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        menuCollectionView.frame = frame
    }
    
    lazy var menuCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "menuCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.accessibilityIdentifier = "menuCollectionView"
        return collectionView
    }()
    
    lazy var underlineBar: UIView = {
        let view = UIView()
        view.backgroundColor = underLineColor
        view.accessibilityIdentifier = "underlineBar"
        return view
    }()
}

// MARK: Methods
extension MUEMenuView {
    public func reload() {
        selectedIndexPath = IndexPath(item: dataSource?.menuViewStartingIndex(self) ?? 0, section: 0)
        titles = dataSource?.menuViewTitles(self) ?? []
        menuCollectionView.reloadData()
    }
    
    public func selectItem(indexPath selectedIndexPath: IndexPath) {
        if self.selectedIndexPath != selectedIndexPath {
            collectionView(menuCollectionView, didSelectItemAt: selectedIndexPath)
        }
    }
    
    private func generateLabel(withText text: String?) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = deselectedColor
        label.font = UIFont(name: "Alexandria-SemiBold", size: 16)
        return label
    }
    
    private func updateSelection(indexPath selectedIndexPath: IndexPath) {
        for i in 0..<titles.count {
            let indexPath = IndexPath(item: i, section: 0)

            if let cell = menuCollectionView.cellForItem(at: indexPath) {
                for subView in cell.contentView.subviews where subView.isKind(of: UILabel.self) {
                    if let subView = subView as? UILabel {
                        subView.textColor = i == selectedIndexPath.item ? selectedColor : deselectedColor
                        
                        if i == selectedIndexPath.item {
                            underlineBar.removeFromSuperview()
                            cell.contentView.addSubview(underlineBar)
                            
                            let y = subView.bounds.height + cell.contentView.bounds.height * 0.2272
                            underlineBar.frame = CGRect(x: 0, y: y, width: subView.bounds.width, height: 2.0)
                        }
                    }
                }
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension MUEMenuView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath)
        
        for subView in cell.contentView.subviews {
            subView.removeFromSuperview()
        }
        
        let label = generateLabel(withText: titles[indexPath.item])
        label.textColor = indexPath == selectedIndexPath ? selectedColor : deselectedColor
        let labelWidth = label.widthForLabel(height: frame.size.height)
        label.frame = CGRect(x: cell.bounds.minX, y: cell.bounds.minY, width: labelWidth, height: cell.bounds.height * 0.5455)
        
        if indexPath == selectedIndexPath {
            underlineBar.removeFromSuperview()
            cell.contentView.addSubview(underlineBar)
            
            let y = label.bounds.height + cell.contentView.bounds.height * 0.2272
            underlineBar.frame = CGRect(x: 0, y: y, width: label.bounds.width, height: 2.0)
        }
        
        cell.contentView.addSubview(label)
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension MUEMenuView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.menuView(self, willDisplay: titles[indexPath.item], forItemAt: indexPath)
        
        if !didSetInitialIndex {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            didSetInitialIndex = true
        }
    }
        
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.menuView(self, didSelectItemAt: indexPath)
        selectedIndexPath = indexPath
        updateSelection(indexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.menuView(self, didDeselectItemAt: indexPath)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension MUEMenuView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if titles.count > 0 {
            let labelWidth = generateLabel(withText: titles[indexPath.item]).widthForLabel(height: frame.size.height)
            return CGSize(width: labelWidth,
                          height: frame.size.height)
        }
        
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return frame.width * 0.0319
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        var totalCellWidth = 0.0
        
        for title in titles {
            let labelWidth = generateLabel(withText: title).widthForLabel(height: frame.size.height)
            totalCellWidth += labelWidth
        }
        
        let totalSpacingWidth = frame.width * 0.0319 * CGFloat(titles.count - 1)
        
        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let leftInsetAdjusted = max(leftInset, 0) // To avoid negative insets
        
        return UIEdgeInsets(top: 0, left: leftInsetAdjusted, bottom: 0, right: 0)
    }
}

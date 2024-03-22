//
//  MUMenuView.swift
//
//
//  Created by Mehmet Utku Eray on 12.01.2024.
//

import UIKit
import SnapKit

public enum MUMenuViewAlignment: String, RawRepresentable {
    case left
    case center
}

public protocol MUMenuViewDataSource: AnyObject {
    func menuViewMenuItems(_ pager: MUMenuView) -> [MUMenuItem]?
    func menuViewStartingIndex(_ menu: MUMenuView) -> Int
}

public extension MUMenuViewDataSource {
    func menuViewMenuItems(_ pager: MUMenuView) -> [MUMenuItem]? { return [] }
    func menuViewStartingIndex(_ menu: MUMenuView) -> Int { return 0 }
}

public protocol MUMenuViewDelegate: AnyObject {
    func menuView(_ menuView: MUMenuView, willDisplay menuItem: MUMenuItem, forItemAt indexPath: IndexPath)
    func menuView(_ menuView: MUMenuView, didSelectItemAt indexPath: IndexPath)
    func menuView(_ menuView: MUMenuView, didDeselectItemAt indexPath: IndexPath)
}

public extension MUMenuViewDelegate {
    func menuView(_ menuView: MUMenuView, willDisplay menuItem: MUMenuItem, forItemAt indexPath: IndexPath) { }
    func menuView(_ menuView: MUMenuView, didSelectItemAt indexPath: IndexPath) { }
    func menuView(_ menuView: MUMenuView, didDeselectItemAt indexPath: IndexPath) { }
}

public protocol MUMenuViewFlowLayoutDelegate: AnyObject {
    func menuViewSpacingBetweenMenuItems(_ menuView: MUMenuView) -> CGFloat
    func menuView(_ menuView: MUMenuView, sizeForItemAt indexPath: IndexPath) -> CGSize
    func menuViewAlignment(_ menuView: MUMenuView) -> MUMenuViewAlignment
}

public final class MUMenuView: UIView {
    private var didSetConstraints: Bool = false
    private var didSetInitialIndex: Bool = false
    private var selectedIndexPath: IndexPath? = nil
    private var menuItems: [MUMenuItem] = []
    
    public weak var dataSource: MUMenuViewDataSource? = nil
    public weak var delegate: MUMenuViewDelegate? = nil
    public weak var flowLayout: MUMenuViewFlowLayoutDelegate? = nil
    
    public var font: UIFont = .systemFont(ofSize: 16.0)
    public var deselectedColor: UIColor = .darkGray
    public var selectedColor: UIColor = .white
    public var indicatorColor: UIColor = .orange
    
    public var hasIndicator: Bool = true {
        didSet {
            indicatorView.isHidden = !hasIndicator
        }
    }
    
    public var alignment: MUMenuViewAlignment = .center {
        didSet {
            menuCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    public var menuCollectionViewEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            menuCollectionView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(menuCollectionViewEdgeInsets.top)
                make.left.equalToSuperview().offset(menuCollectionViewEdgeInsets.left)
                make.right.equalToSuperview().offset(-menuCollectionViewEdgeInsets.right)
                make.bottom.equalToSuperview().offset(-menuCollectionViewEdgeInsets.bottom)
            }
            setNeedsLayout()
            layoutIfNeeded()
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
    
    // MARK: User Interface
    private func setupUI() {
        addSubview(menuCollectionView)
        
        setNeedsUpdateConstraints()
        updateViewConstraints()
    }
    
    private lazy var menuCollectionView: UICollectionView = {
        let layout = MUCollectionFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "menuCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.accessibilityIdentifier = "menuCollectionView"
        return collectionView
    }()
    
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = indicatorColor
        view.accessibilityIdentifier = "indicatorView"
        return view
    }()
}

// MARK: Methods
extension MUMenuView {
    public func reload() {
        if selectedIndexPath == nil {
            selectedIndexPath = IndexPath(item: dataSource?.menuViewStartingIndex(self) ?? 0, section: 0)
        }
        
        menuItems = dataSource?.menuViewMenuItems(self) ?? []
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
        label.font = font
        return label
    }
    
    private func updateSelection(indexPath selectedIndexPath: IndexPath) {
        for i in 0..<menuItems.count {
            let indexPath = IndexPath(item: i, section: 0)
            
            if let cell = menuCollectionView.cellForItem(at: indexPath) {
                for subView in cell.contentView.subviews where subView.isKind(of: UIStackView.self) {
                    if let stackView = subView as? UIStackView {
                        for arrangedView in stackView.arrangedSubviews {
                            let color = i == selectedIndexPath.item ? selectedColor : deselectedColor
                            if arrangedView.isKind(of: UILabel.self),
                               let label = arrangedView as? UILabel {
                                label.textColor = color
                            }
                            
                            if arrangedView.isKind(of: UIImageView.self),
                               let imageView = arrangedView as? UIImageView {
                                imageView.image = imageView.image?.withTintColor(color, renderingMode: .alwaysOriginal)
                            }
                        }
                        
                        if i == selectedIndexPath.item {
                            indicatorView.removeFromSuperview()
                            indicatorView.frame = CGRect(x: 0,
                                                         y: cell.bounds.height - 2.0,
                                                         width: cell.bounds.width,
                                                         height: 2.0)
                            cell.contentView.addSubview(indicatorView)
                        }
                    }
                }
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension MUMenuView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath)
        let menuItem = menuItems[indexPath.item]
        var stackViewWidth:CGFloat = 0.0

        for subView in cell.contentView.subviews {
            subView.removeFromSuperview()
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = menuItem.spacing ?? 0.0

        let color = indexPath == selectedIndexPath ? selectedColor : deselectedColor
        if menuItem.hasIcon() {
            let imageView = UIImageView(image: menuItem.icon?.withTintColor(color, renderingMode: .alwaysOriginal))
            imageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(imageView)
            stackViewWidth += menuItem.iconSize?.width ?? 0.0
            stackViewWidth += menuItem.spacing ?? 0.0
            
            imageView.snp.makeConstraints { make in
                make.size.equalTo(menuItem.iconSize ?? .zero)
            }
        }
        
        
        let label = generateLabel(withText: menuItems[indexPath.item].title)
        label.textColor = color
        label.textAlignment = UIView().semanticContentAttribute == .forceLeftToRight ? .right : .left
        stackView.addArrangedSubview(label)
        stackViewWidth += label.widthForLabel(height: cell.bounds.height)

        stackView.frame = CGRect(x: cell.bounds.midX - stackViewWidth/2, y: 0 , width: stackViewWidth, height: cell.bounds.height)
        
        if hasIndicator && indexPath == selectedIndexPath {
            indicatorView.removeFromSuperview()
            indicatorView.frame = CGRect(x: 0,
                                         y: cell.bounds.maxY - 2.0,
                                         width: cell.bounds.width,
                                         height: 2.0)
            cell.contentView.addSubview(indicatorView)
        }
        
        cell.contentView.addSubview(stackView)
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension MUMenuView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.menuView(self, willDisplay: menuItems[indexPath.item], forItemAt: indexPath)
        
        if !didSetInitialIndex {
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
extension MUMenuView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let sizeForItemAt = flowLayout?.menuView(self, sizeForItemAt: indexPath) {
            return sizeForItemAt
        } else if menuItems.count > 0 {
            let menuItem = menuItems[indexPath.item]
            var stackViewWidth:CGFloat = 0.0
            
            if menuItem.hasIcon() {
                stackViewWidth += menuItem.iconSize?.width ?? 0.0
                stackViewWidth += menuItem.spacing ?? 0.0
            }
            
            stackViewWidth += generateLabel(withText: menuItem.title).widthForLabel(height: frame.size.height)
            return CGSize(width: stackViewWidth,
                          height: frame.size.height)
        } else {
            return .zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return flowLayout?.menuViewSpacingBetweenMenuItems(self) ?? 24.0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        
        self.alignment = flowLayout?.menuViewAlignment(self) ?? .center
        
        if alignment == .center {
            var totalCellWidth = 0.0
            
            for i in 0..<menuItems.count {
                if let labelWidth = flowLayout?.menuView(self, sizeForItemAt: IndexPath(item: i, section: section)).width {
                    totalCellWidth += labelWidth
                }
            }
            
            let totalSpacingWidth = (flowLayout?.menuViewSpacingBetweenMenuItems(self) ?? 24.0) * CGFloat(menuItems.count - 1)
            
            let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let leftInsetAdjusted = max(leftInset, 0) // To avoid negative insets
            
            return UIEdgeInsets(top: 0, left: leftInsetAdjusted, bottom: 0, right: 0)
        } else {
            return .zero
        }
    }
}

// MARK: Auto Layout
extension MUMenuView {
    private func updateViewConstraints() {
        if !didSetConstraints {
            setupConstraints()
            didSetConstraints = true
        }
    }
    
    private func setupConstraints() {
        menuCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(menuCollectionViewEdgeInsets.top)
            make.left.equalToSuperview().offset(menuCollectionViewEdgeInsets.left)
            make.right.equalToSuperview().offset(-menuCollectionViewEdgeInsets.right)
            make.bottom.equalToSuperview().offset(-menuCollectionViewEdgeInsets.bottom)
        }
    }
}

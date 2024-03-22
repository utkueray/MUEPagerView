//
//  ViewController.swift
//  MUPagerDemo
//
//  Created by Mehmet Utku Eray on 22.03.2024.
//

import UIKit
import MUPager
import SnapKit

class ViewController: UIViewController {
    var didSetConstraints = false
    
    var menuItems: [MUMenuItem] = [MUMenuItem(title: "Page 1"),
                                   MUMenuItem(title: "Page 2"),
                                   MUMenuItem(title: "Page 3"),
                                   MUMenuItem(title: "Page 4")]

    var pageColors: [UIColor] = [.lightGray, .red, .green, .blue]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        pager.reload()
        setupUI()
    }

    // MARK: User Interface
    private func setupUI() {
        view.addSubview(pager)

        view.setNeedsUpdateConstraints()
        updateConstraints()
    }
    
    lazy var pager: MUPagerView = {
        let pager = MUPagerView()
        pager.menuDeselectedColor = .darkGray
        pager.menuSelectedColor = .white
        pager.menuIndicatorColor = .orange
        pager.pagesEdgeInsets = .zero
        pager.delegate = self
        pager.dataSource = self
        return pager
    }()
}

// MARK: MUPagerViewDataSource
extension ViewController: MUPagerViewDataSource {
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
    
}

// MARK: MUPagerViewDelegate
extension ViewController: MUPagerViewDelegate {
    
}


// MARK: Auto Layout
extension ViewController {

    private func updateConstraints() {
        if !didSetConstraints {
            setupConstraints()
            didSetConstraints = true
        }
    }

    private func setupConstraints() {
        pager.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.left.equalTo(view.snp.left)
            make.bottom.equalTo(view.snp.bottom)
            make.right.equalTo(view.snp.right)
        }
    }
}


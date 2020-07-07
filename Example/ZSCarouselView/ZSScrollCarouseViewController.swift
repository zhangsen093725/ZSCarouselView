//
//  ZSScrollCarouseViewController.swift
//  ZSViewUtil_Example
//
//  Created by 张森 on 2020/5/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ZSCarouselView
import ZSViewUtil
import Kingfisher

public func KColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return .init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}

class ZSScrollCarouseViewController: UIViewController, ZSScrollCarouseViewDelegate, ZSScrollCarouseViewDataSource {

    let imageFiles = ["http://ww1.sinaimg.cn/large/b02ee545gy1gdmhz2191mj205603rt8j.jpg",
    "http://ww1.sinaimg.cn/large/b02ee545gy1gdnhcee791j2048097dfs.jpg",
    "http://ww1.sinaimg.cn/large/b02ee545gy1gg85m29vyaj218m0g8ju4.jpg",
    "http://ww1.sinaimg.cn/large/b02ee545gy1gg85iftrngj20wc0b40vc.jpg",
    "http://ww1.sinaimg.cn/large/b02ee545gy1gg85p8ub1ij217818mds9.jpg",
    "http://ww1.sinaimg.cn/large/b02ee545gy1gg85qvp173j21cw1v2apj.jpg",
    "http://ww1.sinaimg.cn/large/b02ee545gy1gg85sa4lsuj20zg0buta4.jpg",
    "http://ww1.sinaimg.cn/large/b02ee545gy1gg8wst5idmj21us0xedki.jpg"]
    
    lazy var carouseCustomView: ZSScrollCarouseCustomView = {
        
        let layout = ZSFocusFlowLayout()
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 300, height: 100)
        layout.scrollDirection = .vertical
        
        let loopScroll = ZSScrollCarouseCustomView(collectionViewLayout: layout, cellClass: ZSScrollCarouseCustomCell.self)
        loopScroll.delegate = self
        loopScroll.dataSource = self
        view.addSubview(loopScroll)
        return loopScroll
    }()
    
    lazy var carouseCustomView2: ZSScrollCarouseCustomView = {
        
        let layout = ZSFocusFlowLayout()
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 200, height: 150)
        layout.scrollDirection = .horizontal
        
        let loopScroll = ZSScrollCarouseCustomView(collectionViewLayout: layout, cellClass: ZSScrollCarouseCustomCell.self)
        loopScroll.delegate = self
        loopScroll.dataSource = self
        view.addSubview(loopScroll)
        return loopScroll
    }()
    
    lazy var carouseFullView: ZSScrollCarouseFullView = {
            
        let loopScroll = ZSScrollCarouseFullView(scrollDirection: .horizontal, cellClass: ZSScrollCarouseCustomCell.self)
            loopScroll.minimumSpacing = 10
            loopScroll.delegate = self
            loopScroll.dataSource = self
            view.addSubview(loopScroll)
            return loopScroll
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
       super.viewWillLayoutSubviews()
        carouseFullView.frame = CGRect(x: (view.frame.width - 300) * 0.5, y: 75, width: 300, height: 150)
        carouseCustomView.frame = CGRect(x: (view.frame.width - 300) * 0.5, y: carouseFullView.frame.maxY + 40, width: 300, height: 150)
        carouseCustomView2.frame = CGRect(x: (view.frame.width - 300) * 0.5, y: carouseCustomView.frame.maxY + 40, width: 300, height: 150)
    }
    
    
    func zs_carouseView(_ carouseView: ZSScrollCarouseView, didSelectedItemFor index: Int) {
         print("\(carouseView) index: \(index)")
    }
    
    func zs_carouseViewDidScroll(_ carouseView: ZSScrollCarouseView, index: Int) {
        print("\(carouseView) index: \(index)")
    }
    
    func zs_numberOfItemcarouseView(_ carouseView: ZSScrollCarouseView) -> Int {
        return imageFiles.count
    }
    
    func zs_configCarouseCell(_ cell: ZSScrollCarouseCell, itemAt index: Int) {
        
        let _cell = cell as? ZSScrollCarouseCustomCell
        
        _cell?.label.backgroundColor = .black
        _cell?.label.textColor = .white
        _cell?.label.text = "\(index)"
        
        cell.imageView.kf.setImage(with: URL(string: imageFiles[index]))
    }
}

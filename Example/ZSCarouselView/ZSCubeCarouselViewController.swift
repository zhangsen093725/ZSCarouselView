//
//  ZSCubeCarouselViewController.swift
//  ZSViewUtil_Example
//
//  Created by 张森 on 2020/5/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ZSCarouselView

class ZSCubeCarouselViewController: UIViewController, ZSCubeCarouselViewDataSource, ZSCubeCarouselViewDelegate {
    
    let videoFile = ["loop cube one",
                     "loop cube two"]
    
    lazy var loopCub: ZSCubeCarouselView = {
        
        let view = ZSCubeCarouselView()
        view.delegate = self
        view.dataSource = self
        self.view.addSubview(view)
        return view
    }()
    
    lazy var cubLabel: UILabel = {
        
        let label = UILabel()
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
//        loop()
    }
    
    func loop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.loopCub.reloadDataSource()
            self.loop()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        loopCub.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
    }
    
    func zs_numberOfItemCubeCarouseView(_ cubeCarouseView: ZSCubeCarouselView) -> Int {
        
        return videoFile.count
    }
    
    func zs_cubeCarouseViewContentView(_ cubeCarouseView: ZSCubeCarouselView) -> UIView {
        
        cubLabel.text = videoFile.first
               
        return cubLabel
    }
    
    func zs_cubeCarouseViewView(_ cubeCarouseView: ZSCubeCarouselView, didSelectedItemFor index: Int) {
        
    }
    
    func zs_cubeCarouseViewFinishView(_ cubeCarouseView: ZSCubeCarouselView, index: Int) {
        
        cubLabel.text = videoFile[index]
    }
    
}

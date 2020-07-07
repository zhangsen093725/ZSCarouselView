//
//  ViewController.swift
//  ZSCarouselView
//
//  Created by zhangsen093725 on 07/03/2020.
//  Copyright (c) 2020 zhangsen093725. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var button2: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("TableView嵌套Plain", for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()
    
    lazy var button: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("TableView", for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let buttonW: CGFloat = 150
        let buttonH: CGFloat = 60
        let buttonX: CGFloat = (view.frame.width - buttonW) * 0.5
        
        button.frame = CGRect(x: buttonX, y: 60, width: buttonW, height: buttonH)
        button2.frame = CGRect(x: buttonX, y: button.frame.maxY + 20, width: buttonW, height: buttonH)
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        
        if sender == button2
        {
            navigationController?.pushViewController(ZSScrollCarouseViewController(), animated: true)
        }
        else
        {
            navigationController?.pushViewController(ZSCubeCarouseViewController(), animated: true)
        }
    }
}

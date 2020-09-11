//
//  MyController.swift
//  Runner
//
//  Created by Admin on 2020/6/18.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

class MyController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
         view.backgroundColor = UIColor.red
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        present(flutterVc!, animated: true) {
            
        }
    }
}

//
//  ViewController.swift
//  XWStatusHud
//
//  Created by key on 16/6/24.
//  Copyright © 2016年 key. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var tmp:UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()

//        dispatch_after(5, dispatch_get_global_queue(0, 0)) {
        
            print("进来了")
//        }
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        XWHud.showMessage("已经断开机器人的链接") { () in
            
            print("哈哈")
            XWHud.hide()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


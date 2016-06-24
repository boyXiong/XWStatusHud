//
//  XWStatusHud.swift
//  XWStatusHud
//
//  Created by key on 16/6/24.
//  Copyright © 2016年 key. All rights reserved.
//

import UIKit


public typealias callBack = Void -> Void

public final class XWHud: NSObject {
    
    
    //MARK:公共方法
    
    /** 显示消息，几秒钟 ,默认 1妙*/
    public static func showMessage(message:String,_ second:NSTimeInterval = 1){
        
        XWStatusHud.sharedHUD.showMessage(message, second: 2)
        
    }
    /** 永久显示消息,点击后，回调 默认为 空*/
    public static func showMessage(message:String, action:callBack){
        
        
        XWStatusHud.sharedHUD.showMessageAction(message, action:action)
    }
    
    /** 显示消息，耗时操作 几秒钟 ,默认 1妙*/
    public static func showMessageTimeConsuming(message:String){
        
        XWStatusHud.sharedHUD.showMessageTimeConsuming(message)
        
    }
    
    
    /** 隐藏 */
    public static func hide(){
        
        XWStatusHud.sharedHUD.hide()
    }
    
}





/************************************ 私有 *************************************/
private let gradientDuration_ = 0.5
private var hudStatus_:Int = 0



@objc protocol XWhudAnimating {
    
    func startAnimation(duration:NSTimeInterval)
    optional func stopAnimation()
}



class XWStatusHud: NSObject {
    
    private struct Constants {
        static let sharedHUD = XWStatusHud()
    }
    
    public class var sharedHUD: XWStatusHud {
        return Constants.sharedHUD
    }
    
    
    var action:callBack?
    
    var rootVC = XWViewController()
    var myWindow = MyWindow()
    
    override init() {
        super.init()
        setup()
    }
    
    func setup(){
        self.myWindow.frame = UIScreen.mainScreen().bounds
        self.myWindow.frame.size.height = 30
        self.myWindow.rootViewController = rootVC
        self.myWindow.windowLevel = UIWindowLevelAlert
        self.myWindow.backgroundColor = UIColor(red: CGFloat(0 / 255.0), green: CGFloat(0 / 255.0), blue: CGFloat(0 / 255.0), alpha: CGFloat(0.8))
        self.myWindow.hidden = false

    }
    
    /** 显示消息，几秒钟 ,默认 1妙*/
    internal func showMessage(message:String, second:NSTimeInterval = 1){
        
        self.rootVC.message = message
        self.rootVC.needActivityView = false
        self.myWindow.startAnimation(second)
        
    }
    
    /** 永久显示消息,点击后，回调 默认为 空*/
    internal func showMessageAction(message:String, action:callBack = {}){
        
        self.rootVC.needActivityView = false
        self.myWindow.startAnimation(-1)
        self.rootVC.message = message
        self.rootVC.action = action


    }
    
    internal func showMessageTimeConsuming(message:String){
        self.rootVC.message = message
        self.rootVC.needActivityView = true
        self.myWindow.startAnimation(-1)

    }
    
    
    /** 隐藏 */
    internal func hide(){
        
        self.myWindow.myHiden()
    }


}


//MARK:MyWindow 类
class MyWindow:UIWindow, XWhudAnimating{
    
    func startAnimation(duration:NSTimeInterval) {
        
        UIView.animateWithDuration(gradientDuration_, animations: {
            self.frame.origin.y = 0
            }) { (flag) in
                
                if duration > 0 {
                    
                    xwDelay(duration, task: {
                        
                        UIView.animateWithDuration(gradientDuration_, animations: {
                            self.frame.origin.y = -self.frame.size.height
                        })
                    })
                }
                
        }
    }
    
    func myHiden(){
        
        UIView.animateWithDuration(gradientDuration_, animations: {
            self.frame.origin.y = -self.frame.size.height
        })
        
    }
    
    
}


//MARK - window的根控制器

class XWViewController:UIViewController{
    
    var action:callBack = {}
    
    //菊花
    private lazy var activityView:UIActivityIndicatorView = {
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        
        return activityView
        }()
    
    
    private lazy var textLable:UILabel = {
        let tmpLable = UILabel(frame: CGRectMake(0, 0, 0, 0))
        tmpLable.textAlignment = NSTextAlignment.Center
        tmpLable.font = UIFont.systemFontOfSize(12)
        tmpLable.textColor = UIColor.whiteColor()
        tmpLable.backgroundColor = UIColor.clearColor()
        return tmpLable
    }()
    
    
    
    internal var message:String?{
        didSet{
            self.textLable.text = message
        }
    }
    
    internal var needActivityView:Bool = false{
        
        didSet{
            needActivityView ? self.activityView.startAnimating() :  self.activityView.stopAnimating()
            self.view.setNeedsLayout()

        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        self.view.addSubview(textLable)
        self.view.addSubview(activityView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(tapAction))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !needActivityView {
            self.textLable.frame = self.view.bounds
        }else{
            self.textLable.frame = self.view.bounds
            self.textLable.frame.origin.x = 50
            self.textLable.frame.size.width -= self.textLable.frame.origin.x - 10
            self.activityView.center = self.textLable.center
            self.activityView.frame.origin.x = 30
        }
    }
    
    
    internal func tapAction(){
        
        self.action()
    }
}



/*************************************** helper *********************************/
public typealias xwTask = (cancel:Bool) -> ()

/** 延迟几秒后 在主线程中 执行闭包 ,返回xwTask 用于拿到后取消 */
public func xwDelay(time: NSTimeInterval, task:dispatch_block_t) -> xwTask? {
    
    func dispatch_later(closure:dispatch_block_t){
        
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(),
            closure)
    }
    
    var closure:dispatch_block_t? = task
    
    var result:xwTask?
    
    let delayedClosure: xwTask = {
        cancel in
        if let realClosure = closure {
            
            if cancel == false {
                
                dispatch_async(dispatch_get_main_queue(), realClosure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatch_later { () -> Void in
        if let delayedClosure = result {
            
            delayedClosure(cancel: false)
        }
    }
    
    return result
}

/** 取消 任务 */
public func xwCancel(task:xwTask?){
    
    task?(cancel:true)
}






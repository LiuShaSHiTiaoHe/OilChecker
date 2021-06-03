//
//  BaseNavigationController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/16.
//

import UIKit

class BaseNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        /// 设置导航栏标题
        let navBar = UINavigationBar.appearance()
        navBar.tintColor = kThemeGreenColor
//        navBar.barTintColor = kNavBarColor
//        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: kBlackColor, NSAttributedString.Key.font: k18Font]

        navBar.isTranslucent = true
        // 右滑返回代理
        self.interactivePopGestureRecognizer?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            // push的时候, 隐藏tabbar
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: 代理：UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.children.count > 1
    }

}

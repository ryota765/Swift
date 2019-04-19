//
//  TabmanViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/03/08.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import Tabman
import Pageboy


class TabViewController: TabmanViewController{
    
    
    private var viewControllers = [UIViewController]()
    let titleList = ["おすすめ", "フォロー"]
    
    override func viewDidLoad() {
        initializeViewControllers()
        super.viewDidLoad()
        
        self.dataSource = self
        
        // Create bar
        let bar = TMBar.ButtonBar()
        //bar.tintColor = UIColor.backGroundBlack
        //bar.backgroundColor = UIColor.white
        //let barView = TMBarView()
        //barView.tintColor = UIColor.backGroundBlack
        //barView.backgroundColor = UIColor.backGroundBlack
        
        bar.layout.interButtonSpacing = 0
        bar.buttons.customize { (button) in
            button.font = button.font.withSize(13)
            button.backgroundColor = UIColor.barBlack
            button.tintColor = UIColor.lightGray
            button.selectedTintColor = UIColor.tabmanOrange
        }
        bar.indicator.tintColor = UIColor.tabmanOrange
        bar.layout.transitionStyle = .snap // Customize
        bar.layout.contentMode = .fit
        
        // Add to view
        addBar(bar, dataSource: self, at: .top)
    }
}


extension TabViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = titleList[index]
        return TMBarItem(title: title)
    }
    
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    func barItem(for tabViewController: TabmanViewController, at index: Int) -> TMBarItemable {
        let title = titleList[index]
        return TMBarItem(title: title)
    }
    
    func initializeViewControllers() {
        // Add ViewControllers
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let recommendViewController = storyboard.instantiateViewController(withIdentifier: "RecommendVC") as! RecommendViewController
        let followViewController = storyboard.instantiateViewController(withIdentifier: "FollowVC") as! FollowViewController
        viewControllers = [recommendViewController, followViewController]
    }
}

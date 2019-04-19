//
//  TabmanViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/03/08.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import Tabman
import Pageboy


class TabmanViewController: TabmanViewController{
    
    private var viewControllers = [UIViewController]()
    let titleList = ["おすすめ", "フォロー"]
    
    override func viewDidLoad() {
        initializeViewControllers()
        super.viewDidLoad()
        
        self.dataSource = self
        
        // Create bar
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap // Customize
        bar.layout.contentMode = .fit
        
        // Add to view
        addBar(bar, dataSource: self, at: .top)
    }
}


extension TabmanViewController: PageboyViewControllerDataSource, TMBarDataSource {
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
        let userSearchViewController = storyboard.instantiateViewController(withIdentifier: "UserSearchVC") as! UserSearchViewController
        let postSearchViewController = storyboard.instantiateViewController(withIdentifier: "PostSearchVC") as! PostSearchViewController
        viewControllers = [userSearchViewController, postSearchViewController]
    }
}

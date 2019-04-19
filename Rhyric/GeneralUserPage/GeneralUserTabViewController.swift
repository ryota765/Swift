//
//  GeneralUserTabViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/03/10.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import Tabman
import Pageboy

class GeneralUserTabViewController: TabmanViewController {
    
    
    private var viewControllers = [UIViewController]()
    let titleList = ["投稿", "保存"]
    
    override func viewDidLoad() {
        initializeViewControllers()
        super.viewDidLoad()
        
        self.dataSource = self
        
        // Create bar
        let bar = TMBar.ButtonBar()
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

extension GeneralUserTabViewController: PageboyViewControllerDataSource, TMBarDataSource {
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
        let generalUserPostViewController = storyboard.instantiateViewController(withIdentifier: "GeneralPostVC") as! GeneralUserPostViewController
        let generalUserSaveViewController = storyboard.instantiateViewController(withIdentifier: "GeneralSaveVC") as! GeneralUserSaveViewController
        viewControllers = [generalUserPostViewController, generalUserSaveViewController]
    }
}

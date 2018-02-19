//
//  TabBarController.swift
//  GameTracker
//
//  Created by Tran Julien on 11/02/2018.
//  Copyright © 2018 Julien Tran. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    @IBOutlet weak var AddWishButton: UIBarButtonItem!
    
    @IBOutlet weak var AddGameButton: UIBarButtonItem!
    @IBAction func shareTBAction(_ sender: Any) {
        var gvc : GameTableViewController  = self.childViewControllers[0].childViewControllers[0] as! GameTableViewController
        gvc.shareGames(sender)
    }
    
    var statut = "Collection"
    //var rightNavItems: [UIBarButtonItem]
    var addButton : UIBarButtonItem? = nil
    var wishButton : UIBarButtonItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.89, green:0.09, blue:0.14, alpha:1.0)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let image = UIImage(named: "Logo")
        navigationItem.titleView = UIImageView(image: image)
        
        addButton = AddGameButton
        wishButton = AddWishButton
        
        navigationItem.setRightBarButtonItems(nil, animated: true)
        navigationItem.setRightBarButtonItems([addButton!], animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        statut = item.title!
        if(item.title == "Collection") {
            navigationItem.setRightBarButtonItems([addButton!], animated: true)
        } else {
            if(item.title == "Wishlist") {
                var rightNavItems: [UIBarButtonItem]! = []
                rightNavItems.append(AddWishButton)
                navigationItem.setRightBarButtonItems([wishButton!], animated: true)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddItem" {
            print(statut)
            
            
            var gvc : GameTableViewController  = self.childViewControllers[0].childViewControllers[0] as! GameTableViewController
            
            let navVC = segue.destination as? UINavigationController
            let formVC = navVC?.viewControllers.first as! GameViewController
            formVC.listFilters = gvc.listFilters
            
            gvc.loadFirstScope()
            gvc.searchBar.selectedScopeButtonIndex = 0
            gvc.selectedScopeVar = 0
            gvc.searchBar.text = ""
            gvc.currentSearchText = ""
            gvc.currentGamesArray = gvc.games
            gvc.table.reloadData()
            
            print("Adding new game.")
            
        }
        if segue.identifier == "AddItemWish" {
            print(statut)
            var wvc : WishTableViewController  = self.childViewControllers[1].childViewControllers[0] as! WishTableViewController
            
            let navVC = segue.destination as? UINavigationController
            let formVC = navVC?.viewControllers.first as! WishViewController
            formVC.listFilters = wvc.listFilters
            
            wvc.searchBarWish.selectedScopeButtonIndex = 0;
            wvc.selectedScopeVar = 0
            wvc.searchBarWish.text = ""
            wvc.currentSearchText = ""
            wvc.currentWishesArray = wvc.wishes
            wvc.tableWish.reloadData()
            
            print("Adding new wish.")
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

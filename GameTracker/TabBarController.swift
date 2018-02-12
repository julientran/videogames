//
//  TabBarController.swift
//  GameTracker
//
//  Created by Tran Julien on 11/02/2018.
//  Copyright © 2018 Mario Ban. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    @IBAction func shareTBAction(_ sender: Any) {
          var gvc : GameTableViewController  = self.childViewControllers[0].childViewControllers[0] as! GameTableViewController
        gvc.shareGames(sender)
    }
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "AddItem" {
            
            var gvc : GameTableViewController  = self.childViewControllers[0].childViewControllers[0] as! GameTableViewController

            let navVC = segue.destination as? UINavigationController
            let formVC = navVC?.viewControllers.first as! GameViewController
            formVC.listFilters = gvc.listFilters
            
            gvc.searchBar.selectedScopeButtonIndex = 0;
            gvc.searchBar.text = ""
            gvc.currentGamesArray = gvc.games
            gvc.table.reloadData()
            
            print("Adding new game.")
            
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

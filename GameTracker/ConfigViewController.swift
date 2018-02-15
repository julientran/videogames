//
//  ConfigViewController.swift
//  GameTracker
//
//  Created by Tran Julien on 11/02/2018.
//  Copyright © 2018 Julien Tran. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {
    @IBOutlet weak var ps4UISwitch: UISwitch!
    
    @IBOutlet weak var ps3UISwitch: UISwitch!
    
    @IBOutlet weak var xboxoneUISwitch: UISwitch!
    
    @IBOutlet weak var xbox360UISwitch: UISwitch!
    
    @IBOutlet weak var switchUISwitch: UISwitch!
    
    @IBOutlet weak var n3dsUISwitch: UISwitch!
    
    @IBOutlet weak var pcUISwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

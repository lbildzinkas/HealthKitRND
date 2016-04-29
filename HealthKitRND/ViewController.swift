//
//  ViewController.swift
//  HealthKitRND
//
//  Created by Luiz Bildzinkas on 4/7/16.
//  Copyright © 2016 Luiz Bildzinkas. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var healthKitManager = HealthKitManager()
    
    @IBAction func obterPermissoes() {
        healthKitManager.AutorizeHealthKit{(authorize, error) -> Void in
            if authorize{
                print("Authorized")
            }
            else{
                print("Not")
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let main = (segue.destinationViewController as! UINavigationController).topViewController as? MainTableViewController {
//            main.healthKitManager = healthKitManager;
//        }
        if let main = segue.destinationViewController as? MainTableViewController{
            main.healthKitManager = healthKitManager
        }
    }
}


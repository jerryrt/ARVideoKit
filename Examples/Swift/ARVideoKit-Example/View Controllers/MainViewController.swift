//
//  MainViewController.swift
//  ARVideoKit-Example
//
//  Created by Ahmed Bekhit on 11/21/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet var skBtn: UIButton!
    @IBOutlet var scnBtn: UIButton!
    @IBOutlet var rkBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skBtn.layer.cornerRadius = skBtn.bounds.height/2
        scnBtn.layer.cornerRadius = scnBtn.bounds.height/2
        rkBtn.layer.cornerRadius = rkBtn.bounds.height/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

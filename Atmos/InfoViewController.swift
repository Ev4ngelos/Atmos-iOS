//
//  InfoViewController.swift
//  Atmos
//
//  Created by Evangelos on 06/04/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//
import UIKit


class InfoViewController: UIViewController {
    //MARK: Properties
    
    
    @IBAction func privacyButtonPress(sender: UIButton) {
        let url = NSURL(string: "http://beja.m-iti.org/web/?q=node/11")!
        UIApplication.sharedApplication().openURL(url)
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
    }//endViewDidLoad()
    


}//endInfoViewController.swift
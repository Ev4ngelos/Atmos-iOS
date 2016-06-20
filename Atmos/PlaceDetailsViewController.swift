//
//  PlaceDetailsViewController.swift
//  Atmos
//
//  Created by Evangelos on 03/01/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//

import UIKit

class PlaceDetailsViewController: UIViewController {
    var place: Place?
    
    //MARK: Now Properties
    @IBOutlet weak var nowWeatherIcon: UIImageView!
    @IBOutlet weak var nowTempLabel: UILabel!
    @IBOutlet weak var nowWindIcon: UIImageView!
    @IBOutlet weak var nowCrowdLabel: UILabel!
    //MARK: Later Properties
    @IBOutlet weak var laterWeatherIcon: UIImageView!
    @IBOutlet weak var laterTempLabel: UILabel!
    @IBOutlet weak var laterWindIcon: UIImageView!
    @IBOutlet weak var laterCrowdLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
      //  self.automaticallyAdjustsScrollViewInsets = false
//        dynamically resize scrollview to screen's size
       // resizeScrolView()
        if let place = place {
            //NOW FIELDS
            navigationItem.title = "\(place.getName()), \(place.getCountry())"
            nowWeatherIcon.image = place.getCrowdReport().getWeatherIcon()
            nowTempLabel.text = place.getCrowdReport().getTemperature() + " °C"
            nowWindIcon.image = place.getCrowdReport().getWindIcon()
            if(Int(place.getCrowdReport().getPool()) > 1){
                nowCrowdLabel.text = place.getCrowdReport().getPool() + " people"
            } else {
                nowCrowdLabel.text = place.getCrowdReport().getPool() + " person"
            }
            
            //LATER FIELDS
            laterWeatherIcon.image = place.getCrowdPrediction().getWeatherIcon()
            laterTempLabel.text = place.getCrowdPrediction().getTemperature() + " °C"
            laterWindIcon.image = place.getCrowdPrediction().getWindIcon()
            if(Int(place.getCrowdPrediction().getPool()) > 1){
                laterCrowdLabel.text = place.getCrowdPrediction().getPool() + " people"
            } else {
                laterCrowdLabel.text = place.getCrowdPrediction().getPool() + " person"
            }

            
            //wind missing
        }//endIf

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    func loadNowWeather() {
        checkDayOrNight()//checking if daylight
        if let place = place {
            navigationItem.title = "\(place.getName()), \(place.getCountry())"
            nowWeatherIcon.image = place.getCrowdReport().getWeatherIcon()
            nowTempLabel.text = place.getCrowdReport().getTemperature() + " °C"
            nowCrowdLabel.text = place.getCrowdReport().getPool() + " people"
            //wind missing
       }//endIf
    }
    
    func loadLaterWeather() {/*load weather updates from predictions about later*/}
    
    func checkDayOrNight(){/*update icons for night and day*/}
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}//endPlaceDetailsViewController.swift

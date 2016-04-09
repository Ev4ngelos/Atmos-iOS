//
//  LaterViewController.swift
//  Atmos
//
//  Created by Evangelos on 02/01/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//

import UIKit

class LaterViewController: UIViewController {
    //MARK: Properties
    let toolbox = PlacesViewController.variables.toolbox
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempSlider: UISlider!
    @IBAction func tempSliderControl(sender: UISlider) {
        let temp = Int(sender.value-20)
        tempLabel.text = String(temp)+" °C"
        NSLog("Temp Slider: \(sender.value)")
        
    }//endTempSliderControl()
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherSlider: UISlider!
    @IBAction func weatherSliderControl(sender: UISlider) {
        weatherSlider.value = Float(Int(sender.value))//changing movement from continuous to discrete
        NSLog("Weather Slider: \(Int(sender.value))")
        weatherIcon.image=UIImage(named: toolbox.selectWeatherIcon(String(Int(sender.value)+1), timeframe: "later", position: toolbox.actualPosition))
    }//endWeatherSliderControl()
    
    @IBOutlet weak var windIcon: UIImageView!
    @IBOutlet weak var windSlider: UISlider!
    
    @IBAction func windSliderControl(sender: UISlider) {
        windSlider.value = Float(Int(sender.value))
        windIcon.image=UIImage(named: toolbox.selectWindIcon(String(Int(sender.value)+1)))
        NSLog("Wind Slider: \(sender.value)")
    }//endWindSliderControl()
    //MARK: Bar Icon Properties

    @IBOutlet weak var barWeatherIcon4: UIImageView!
    @IBOutlet weak var barWeatherIcon5: UIImageView!
    @IBOutlet weak var barWeatherIcon6: UIImageView!
    @IBOutlet weak var barWeatherIcon7: UIImageView!
    @IBOutlet weak var barWeatherIcon8: UIImageView!
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    @IBAction func submitButtonControl(sender: UIBarButtonItem) {
        let prediction = Report()
        prediction.setType("prediction")
        prediction.setTemperature(String(Int(tempSlider.value - 20))) //getting and normalizing (-20 to +40 C) temperature slider value
        prediction.setWeather(String(Int(weatherSlider.value) + 1)) //getting and normalizing (1-8) weather slider value
        prediction.setWind(String(Int(windSlider.value) + 1)) //getting and normalizing (1-5) wind slider value
        
        prediction.getPosition().setAddress(toolbox.actualPosition.getAddress())
        prediction.getPosition().setRegion(toolbox.actualPosition.getRegion())
        prediction.getPosition().setCountry(toolbox.actualPosition.getCountry())
        prediction.getPosition().setLatitude(toolbox.actualPosition.getLatitude())
        prediction.getPosition().setAltitude(toolbox.actualPosition.getAltitude())
        prediction.getPosition().setAccuracy(toolbox.actualPosition.getAccuracy())
        prediction.getPosition().setLongitude(toolbox.actualPosition.getLongitude())
        prediction.getPosition().setLocalTimestamp(toolbox.getLocalTimestamp())
        prediction.getPosition().setServerTimestamp(toolbox.convertTime("Europe/Zurich", date: NSDate())) //converting current timestamp to server timezone timestamp
        prediction.getPosition().setLocalTimeZone(toolbox.actualPosition.getLocalTimeZone())
        
        NSLog("--------PREPARING TO UPLOAD prediction-----------")
        NSLog("-Address: \(prediction.getPosition().getAddress())")
        NSLog("-Region: \(prediction.getPosition().getRegion())")
        NSLog("-Country: \(prediction.getPosition().getCountry())")
        NSLog("-Lat: \(prediction.getPosition().getLatitude())")
        NSLog("-Lng: \(prediction.getPosition().getLongitude())")
        NSLog("-Local Timestamp: \(prediction.getPosition().getLocalTimestamp())")
        NSLog("-Local Time Zone: \(prediction.getPosition().getLocalTimeZone())")
        NSLog("-Server Timestamp: \(prediction.getPosition().getServerTimestamp())")
        
        NSLog("-Type: \(prediction.getType())")
        NSLog("-Temp: \(prediction.getTemperature())")
        NSLog("-Weather: \(prediction.getWeather())")
        NSLog("-Wind: \(prediction.getWind())")
        NSLog("---------------------------------------------")
        
        toolbox.uploadData(prediction) { (status) -> () in
            NSLog("Upload status: \(status)")
            //MARK: Respond to User
            var title: String
            var msg: String
            if(status == "1"){
                title = "Thank you!"
                msg = "Your prediction has been recorded."
            } else {
                title = "We are sorry :("
                msg = "Weather server is offline. Try again later."
            }
            let alert = UIAlertView()
            alert.delegate = self
            alert.title =  title
            alert.message = msg
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("-->Later Tab loaded")
        updateWeatherBar()//updates the weather bar icons based on daytime and night-time
       // updateWeatherIcon(Int(weatherSlider.value))
       weatherIcon.image=UIImage(named: toolbox.selectWeatherIcon(String(Int(weatherSlider.value)+1), timeframe: "later", position: toolbox.actualPosition))
       
        _ = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "refreshGUI", userInfo: nil, repeats: true)//this starts a timer for updating GUI
    }//endOnViewDidLoad()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: Update GUI loop for implicit GUI updates
    func refreshGUI(){
        updateWeatherBar()//updates the weather bar icons based on daytime and night-time
        //updateWeatherIcon(Int(weatherSlider.value))
        weatherIcon.image=UIImage(named: toolbox.selectWeatherIcon(String(Int(weatherSlider.value)+1), timeframe: "later", position:toolbox.actualPosition))
    }//endRefreshGUI()

    //MARK: update GUI functions
    func updateWeatherBar(){
        if (toolbox.nightTimeIn3h == false) { //if day load day icons on the bar
            barWeatherIcon4.image = UIImage(named:"bar_sun_cloud4")
            barWeatherIcon5.image = UIImage(named:"bar_sun_cloud3")
            barWeatherIcon6.image = UIImage(named:"bar_sun_cloud2")
            barWeatherIcon7.image = UIImage(named:"bar_sun_cloud1")
            barWeatherIcon8.image = UIImage(named:"bar_sun_clear")
        } else {
            barWeatherIcon4.image = UIImage(named:"bar_moon_cloud4")
            barWeatherIcon5.image = UIImage(named:"bar_moon_cloud3")
            barWeatherIcon6.image = UIImage(named:"bar_moon_cloud2")
            barWeatherIcon7.image = UIImage(named:"bar_moon_cloud1")
            barWeatherIcon8.image = UIImage(named:"bar_moon_clear")
        }//endElse
    }//endWeatherBar()
}//endLaterViewController.swift

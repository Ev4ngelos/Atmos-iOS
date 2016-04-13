//
//  SecondViewController.swift
//  Atmos
//
//  Created by Evangelos on 02/01/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//

import UIKit
import CoreLocation

class NowViewController: UIViewController, CLLocationManagerDelegate {//this class handles the fucntionality of Now tab
    //MARK: Properties
    let toolbox = PlacesViewController.variables.toolbox
    //let toolbox: Toolbox = Toolbox()
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
        //updateWeatherIcon(Int(sender.value))
        if(toolbox.locationAvailable()){
            weatherIcon.image=UIImage(named: toolbox.selectWeatherIcon(String(Int(weatherSlider.value)+1), timeframe: "now", position: toolbox.actualPosition))
        } else {
            weatherIcon.image = UIImage(named: toolbox.selectWeatherIconWhenNoLocation(String(Int(weatherSlider.value)+1)))
        }
        NSLog("Slider: \((String(Int(sender.value))))")
    }//weatherSliderControl()
    
    @IBOutlet weak var windIcon: UIImageView!
    @IBOutlet weak var windSlider: UISlider!
    @IBAction func windSliderControl(sender: UISlider) {
        windSlider.value = Float(Int(sender.value))
        windIcon.image=UIImage(named: toolbox.selectWindIcon(String(Int(sender.value)+1)))
        NSLog("Wind Slider: \(sender.value)")
    }//endWindSliderControl
    
    //MARK: Bar Icon Properties
    @IBOutlet weak var barWeatherIcon4: UIImageView!
    @IBOutlet weak var barWeatherIcon5: UIImageView!
    @IBOutlet weak var barWeatherIcon6: UIImageView!
    @IBOutlet weak var barWeatherIcon7: UIImageView!
    @IBOutlet weak var barWeatherIcon8: UIImageView!
    
    //MARK: Submit Button Properties
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    @IBAction func submitButtonControl(sender: UIBarButtonItem) {
        if (toolbox.locationAvailable() == true){//if location available
            let report = Report()
            report.setType("report")
            report.setTemperature(String(Int(tempSlider.value - 20))) //getting and normalizing (-20 to +40 C) temperature slider value
            report.setWeather(String(Int(weatherSlider.value) + 1)) //getting and normalizing (1-8) weather slider value
            report.setWind(String(Int(windSlider.value) + 1)) //getting and normalizing (1-5) wind slider value
            
            report.getPosition().setAddress(toolbox.actualPosition.getAddress())
            report.getPosition().setRegion(toolbox.actualPosition.getRegion())
            report.getPosition().setCountry(toolbox.actualPosition.getCountry())
            report.getPosition().setLatitude(toolbox.actualPosition.getLatitude())
            report.getPosition().setAltitude(toolbox.actualPosition.getAltitude())
            report.getPosition().setAccuracy(toolbox.actualPosition.getAccuracy())
            report.getPosition().setLongitude(toolbox.actualPosition.getLongitude())
            report.getPosition().setLocalTimestamp(toolbox.getLocalTimestamp())
            report.getPosition().setServerTimestamp(toolbox.convertTime("Europe/Zurich", date: NSDate())) //converting current timestamp to server timezone timestamp
            report.getPosition().setLocalTimeZone(toolbox.actualPosition.getLocalTimeZone())
            
            NSLog("--------PREPARING TO UPLOAD REPORT-----------")
            NSLog("-Address: \(report.getPosition().getAddress())")
            NSLog("-Region: \(report.getPosition().getRegion())")
            NSLog("-Country: \(report.getPosition().getCountry())")
            NSLog("-Lat: \(report.getPosition().getLatitude())")
            NSLog("-Lng: \(report.getPosition().getLongitude())")
            NSLog("-Local Timestamp: \(report.getPosition().getLocalTimestamp())")
            NSLog("-Local Time Zone: \(report.getPosition().getLocalTimeZone())")
            NSLog("-Server Timestamp: \(report.getPosition().getServerTimestamp())")
            
            NSLog("-Type: \(report.getType())")
            NSLog("-Temp: \(report.getTemperature())")
            NSLog("-Weather: \(report.getWeather())")
            NSLog("-Wind: \(report.getWind())")
            NSLog("---------------------------------------------")
            
            toolbox.uploadData(report) { (status) -> () in
                NSLog("Upload status: \(status)")
                //MARK: Respond to User
                var title: String
                var msg: String
                if(status == "1"){
                    title = "Thank you!"
                    msg = "Your observation has been recorded."
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
        } else { //if location is not available inform user
            let title = "Location Unavailable"
            let msg = "Atmos needs to know your current location before uploading a weather report. Please enable location services in Settings and make sure Atmos has location permissions granted."
            let alertController = UIAlertController (title: title, message: msg, preferredStyle: .Alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                if let url = settingsUrl {
                    UIApplication.sharedApplication().openURL(url)
                }//endIf
            }//endSettingsAction
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil);
        }//endElse
    }//endSubmitButtonControl()
    
    //MARK: VIEW DID LOAD ()
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("-->Now Tab loaded")
        
        
        //NSLog("Requesting location authorization...")
        updateWeatherBar()//updates the weather bar icons based on daytime and night-time
        if(toolbox.locationAvailable()){
            weatherIcon.image=UIImage(named: toolbox.selectWeatherIcon(String(Int(weatherSlider.value)+1), timeframe: "now", position: toolbox.actualPosition))
        } else {
            weatherIcon.image = UIImage(named: toolbox.selectWeatherIconWhenNoLocation(String(Int(weatherSlider.value)+1)))
        }
        _ = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "refreshGUI", userInfo: nil, repeats: true)//this starts a timer for updating GUI
        
    }//endViewDidLoad()
    
    
    //MARK: Update GUI loop for implicit GUI updates
    func refreshGUI(){
        updateWeatherBar()//updates the weather bar icons based on daytime and night-time
        if(toolbox.locationAvailable()){
            weatherIcon.image=UIImage(named: toolbox.selectWeatherIcon(String(Int(weatherSlider.value)+1), timeframe: "now", position: toolbox.actualPosition))
        } else {
            weatherIcon.image = UIImage(named: toolbox.selectWeatherIconWhenNoLocation(String(Int(weatherSlider.value)+1)))
        }
    }//endRefreshGUI()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }//endDidReceiveMemoryWarning()
    
    func updateWeatherBar(){
        if(toolbox.locationAvailable() == true){//if location is available
            if (toolbox.nightTime == false) { //if day load day icons on the bar
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
        }else { //if location not available load icons as during daytime
            barWeatherIcon4.image = UIImage(named:"bar_sun_cloud4")
            barWeatherIcon5.image = UIImage(named:"bar_sun_cloud3")
            barWeatherIcon6.image = UIImage(named:"bar_sun_cloud2")
            barWeatherIcon7.image = UIImage(named:"bar_sun_cloud1")
            barWeatherIcon8.image = UIImage(named:"bar_sun_clear")
        }
    }//endWeatherBar
    

    
}//endNowViewController.swift


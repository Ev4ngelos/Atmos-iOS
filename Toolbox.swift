//
//  Toolbox.swift
//  Atmos
//
//  Created by Evangelos on 07/01/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import CoreMotion
import UIKit
import Alamofire
import SwiftyJSON
import SystemConfiguration

class Toolbox: NSObject, CLLocationManagerDelegate {
    var initialized = false
    var locationUpdatesActive = false
    var locationManager = CLLocationManager()
    var location: CLLocation?
    var nightTime = false
    var nightTimeIn3h = false
    var actualPosition = Position()
    var measurement = Measurement()
    let altimeter = CMAltimeter()
    let motionManager = CMMotionManager()
    class var manager: Toolbox {
        return SharedToolbox
    }
    
    override init () {
        super.init()
        actualPosition.setLatitude("46.0110928799154")
        actualPosition.setLongitude("8.95758408145778")
        initializeLocationManager()
    }//endInit()
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        
        NSLog("lat: \(location!.coordinate.latitude) lng:  \(location!.coordinate.longitude) alt: \(Int(location!.altitude)) m")
        if (initialized == false){ //if the app hasnt been initialized yet
            actualPosition.setLatitude(String(location!.coordinate.latitude))
            actualPosition.setLongitude(String(location!.coordinate.longitude))
            actualPosition.setLocalTimeZone(NSTimeZone.localTimeZone().name)
            actualPosition.setSunriseTime(calculateSunrise(actualPosition).getSunriseTime())
            actualPosition.setSunsetTime(calculateSunset(actualPosition).getSunsetTime())
            actualPosition.setAltitude(String(Int(location!.altitude)))
            actualPosition.setAccuracy(String(location!.horizontalAccuracy))
            actualPosition = locateActualPosition(actualPosition)
            
            measurement.setLocalTimestamp(getLocalTimestamp())
            measurement.setServerTimestamp(convertTime("Europe/Zurich", date: NSDate()))
            initializeAltimeter()
            // initializeProximity() //deactivated as it doesnt produce numerical values like in Android, it just deactivates the screen.
            initializeAccelerometer()
            initializeMagnetometer()
            initialized = true
        }//endIf
        
    }//endLocationManager()
    
    func initializeLocationManager(){
        NSLog("-->Initializing location manager")
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest //change to kCLLocationAccuracyHundredMeters to conserve battery resources
        self.locationManager.startUpdatingLocation()
        locationUpdatesActive = true
    }//endInitializeLocationManager()
    
    
    func calculateSunrise(position: Position) -> Position {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT");
        let remoteToday = dateFormatter.dateFromString(convertTime(position.getLocalTimeZone(), date: NSDate()))!
        let calculator = EDSunriseSet(date: remoteToday, timezone: NSTimeZone(name: position.getLocalTimeZone()), latitude: (Double(position.getLatitude()))!,longitude:(Double(position.getLongitude()))!)
        let calendar = NSCalendar.currentCalendar()
        let sunriseComponents = NSDateComponents()
        sunriseComponents.year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: remoteToday)
        sunriseComponents.month = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: remoteToday)
        sunriseComponents.day = NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: remoteToday)
        sunriseComponents.hour = calculator!.localSunrise.hour
        sunriseComponents.minute = calculator!.localSunrise.minute
        sunriseComponents.second = calculator!.localSunrise.second
        sunriseComponents.timeZone = NSTimeZone(name: position.getLocalTimeZone())
        let  sunriseTime = calendar.dateFromComponents(sunriseComponents)
        dateFormatter.timeZone = NSTimeZone(name:position.getLocalTimeZone())
        let strSunrise = dateFormatter.stringFromDate(sunriseTime!)
        position.setSunriseTime(strSunrise)
        //    NSLog("++Calculated surnise: \(strSunrise) for \(position.getRegion()) with timezone: \(position.getTimeZone()) lat: \(position.getLatitude()) lng: \(position.getLongitude()))")
        return position
    }//endCalculateSunrise()
    
    func calculateSunset(position: Position) -> Position {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT");
        let remoteToday = dateFormatter.dateFromString(convertTime(position.getLocalTimeZone(), date: NSDate()))!
        let calculator = EDSunriseSet(date: remoteToday, timezone: NSTimeZone(name: position.getLocalTimeZone()), latitude: (Double(position.getLatitude()))!,longitude:(Double(position.getLongitude()))!)
        let calendar = NSCalendar.currentCalendar()
        let sunsetComponents = NSDateComponents()
        sunsetComponents.year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: remoteToday)
        sunsetComponents.month = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: remoteToday)
        sunsetComponents.day = NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: remoteToday)
        sunsetComponents.hour = calculator!.localSunset.hour
        sunsetComponents.minute = calculator!.localSunset.minute
        sunsetComponents.second = calculator!.localSunset.second
        sunsetComponents.timeZone = NSTimeZone(name: position.getLocalTimeZone())
        let  sunsetTime = calendar.dateFromComponents(sunsetComponents)
        dateFormatter.timeZone = NSTimeZone(name:position.getLocalTimeZone())
        let strSunset = dateFormatter.stringFromDate(sunsetTime!)
        position.setSunsetTime(strSunset)
        //    NSLog("++Calculated sunset: \(strSunset) for \(position.getRegion()) with timezone: \(position.getTimeZone()) lat: \(position.getLatitude()) lng: \(position.getLongitude()))")
        return position
    }
    
    func isNight(offsetHour:Int,  position: Position) -> Bool {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT");
        let remoteSunrise = dateFormatter.dateFromString(position.getSunriseTime())!
        let remoteSunset = dateFormatter.dateFromString(position.getSunsetTime())!
        let nowStr = convertTime(position.getLocalTimeZone(), date: NSDate())
        var now = dateFormatter.dateFromString(nowStr)!
        //  NSLog("-->Checking time \(nowStr) in \(position.getRegion()) with sunrise \(remoteSunrise) and sunset \(remoteSunset)")
        now = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Hour, value: offsetHour, toDate: now, options: NSCalendarOptions.init(rawValue: 0))!
        //XOR boolean operator is "!=" from what in Java would be "|"
        if ((now.compare(remoteSunrise) == NSComparisonResult.OrderedAscending) != (now.compare(remoteSunset) == NSComparisonResult.OrderedDescending)) {
            if(offsetHour == 0){
                //     NSLog("Now \(now) is night in \(position.getRegion()) with Sunrise: \(position.getSunriseNSDate()) and Sunset: \(position.getSunsetNSDate())")
                nightTime = true
                return true
            }else {
                //NSLog("In \(offsetHour)h will be night")
                //    NSLog("At \(now) will be night in \(position.getRegion()) with Sunrise: \(position.getSunriseNSDate()) and Sunset: \(position.getSunsetNSDate())")
                nightTimeIn3h = true
                return true
            }//endIf
        } else {
            if(offsetHour == 0){
                //    NSLog("Now \(now) is day in \(position.getRegion()) with Sunrise: \(position.getSunriseNSDate()) and Sunset: \(position.getSunsetNSDate())")
                nightTime = false
                return false
            } else {
                //     NSLog("At \(now) will be day in \(position.getRegion()) with Sunrise: \(position.getSunriseNSDate()) and Sunset: \(position.getSunsetNSDate())")
                nightTimeIn3h = false
                return false
            }//endEndIf
        }//endIf
    }//endIsNight
    
    func getLocalTimestamp() -> String {
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        NSLog("Current Timestamp: \(dateFormatter.stringFromDate(now))")
        return dateFormatter.stringFromDate(now)
    }
    
    func convertTime(targetTimezone: String, date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //    let strOriginal = dateFormatter.stringFromDate(date)
        dateFormatter.timeZone = NSTimeZone(name:targetTimezone)
        let strConverted = dateFormatter.stringFromDate(date)
        //  NSLog("Converted FROM: \(strOriginal), \(dateFormatter.timeZone.name) TO: \(strConverted), \(dateFormatter.timeZone.name) ")
        return strConverted
    }
    
    func getIdentifierForVendor() -> String {
        return UIDevice.currentDevice().identifierForVendor!.UUIDString
    }
    
    func getDeviceName() -> String {
        return String(UIDevice.currentDevice().type)
    }
    
    func getAppVersion() -> String {
        let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] //Current app version
        let nsObjectString = nsObject as! String
        //  NSLog("Atmos version: \(nsObjectString)")
        return nsObjectString
    }
    
    func getIOSVersion() -> String {
        return UIDevice.currentDevice().systemName + " " + UIDevice.currentDevice().systemVersion
    }
    
    func getMemoryUsed() -> String { //Get RAM used by the app
        var info = task_basic_info()
        var count = mach_msg_type_number_t(sizeofValue(info))/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(&info) {
            
            task_info(mach_task_self_,
                      task_flavor_t(TASK_BASIC_INFO),
                      task_info_t($0),
                      &count)
        }
        
        if kerr == KERN_SUCCESS {
            NSLog("Memory in use (in bytes): \(info.resident_size)")
            NSLog("Memory in use (in MBs): \((info.resident_size/1024)/1024)")
        }
        else {
            NSLog("Error with task_info(): " + (String.fromCString(mach_error_string(kerr)) ?? "unknown error"))
        }
        return String((info.resident_size/1024)/1024) //converting to KBs then MBs and then to a String
    }//endGetMemoryUsed()
    
    //MARK: Connect and Upload Modules
    func connectToWeatherServer(completionHandler: (deviceId: String) -> ()){//works
        let url = "http://derecho.inf.usi.ch/Atmos/ios/connect_ios.php"
        let deviceFeatures: Array<[String : AnyObject]> = [[
            "imei" : getIdentifierForVendor(),
            "name" : getDeviceName(),
            "version" : getAppVersion(),
            "android" : getIOSVersion(),
            "ram_used" : getMemoryUsed(),
            "last_upload_time" : getLocalTimestamp()
            ]]
        doRequest2(url, parameters: deviceFeatures) { (data) -> () in
            let key = String(data["key"]).stringByReplacingOccurrencesOfString("\"", withString: "")
            completionHandler(deviceId: key)
        }
    }//endConnectToServer()
    
    func searchForPlaces(chars: String, completionHandler: (placesFound: Array<Place>) -> ()) {//works
        //   searchingForAvailablePlaces = true
        var placesFound = [Place]()
        
        let url = "http://derecho.inf.usi.ch/Atmos/ios/get_available_places_ios.php"
        let jsonCharacters: Array<[String: AnyObject]> = [["characters" : chars]]
        //var placesJSON = doRequest(url, parameters: jsonCharacters)
        
        doRequest2(url, parameters: jsonCharacters) { (data) -> () in
            
            NSLog("Data returned: \(data)") // WORKS ;)
            //HERE you out code of what you want to happen when the task finishes
            let placesJSON = data
            if placesJSON.isEmpty == false {
                for (_,subJson) in placesJSON["places"] {
                    NSLog("Looping over JSON")
                    let place = Place()
                    place.setName(subJson["region"].string!)
                    place.setCountry(subJson["country"].string!)
                    placesFound.append(place)
                }//endFor
                
                NSLog("Loaded table: "+String(placesFound))
                completionHandler(placesFound: placesFound)
                //          self.searchingForAvailablePlaces = false
            }//endIf
            
        }//endDoRequest2()
        
    }//endGetAvaialblePlaces()
    
    func getCrowdReports(places:[Place], completionHandler: (crowdReports: Array<Place>) ->()){
        let url = "http://derecho.inf.usi.ch/Atmos/ios/get_crowd_reports_ios.php"
        var jsonPlaces = Array<[String: AnyObject]>()
        var crowdReportsForPlaces = [Place]()
        for place in places {
            NSLog("Putting \(place.getName()) in JSON")
            let dictionary: [String:AnyObject]
            dictionary = ["place_name": place.getName(), "place_country": place.getCountry()]
            jsonPlaces.append(dictionary)
        }//endFor
        NSLog("\(places.count) JSONPlaces requesting weather updates: \(jsonPlaces) size: \(jsonPlaces.count)")
        if jsonPlaces.count > 0 {
            
            //doRequest(url, parameters: jsonPlaces)
            
            doRequest2(url, parameters: jsonPlaces) { (data) -> () in
                
                //      NSLog("Data returned: \(data)") // WORKS ;)
                //HERE you out code of what you want to happen when the task finishes
                let updatesJSON = data
                if updatesJSON.isEmpty == false {
                    for (_,subJson) in updatesJSON["weather"] {
                        NSLog("Looping over JSON")
                        let place = Place()
                        let crowdReport = CrowdReport()
                        let position = Position()
                        
                        //MARK: Start Loading Place Object
                        place.setName(subJson["place_name"].string!)
                        place.setCountry(subJson["place_country"].string!)
                        
                        //MARK: Loading Position Object
                        // let position = Position(address:"default", region: place.getName(), country: place.getCountry(), latitude: subJson["latitude"].string!, longitude: subJson["longitude"].string!, timestamp:subJson["time_calculated"].string!, timeZone: subJson["time_zone"].string!)
                        
                        position.setRegion(place.getName())
                        position.setCountry(place.getCountry())
                        position.setLocalTimeZone(subJson["time_zone"].string!)
                        position.setLatitude(subJson["latitude"].string!)
                        position.setLongitude(subJson["longitude"].string!)
                        position.setSunriseTime(self.calculateSunrise(position).getSunriseTime())
                        position.setSunsetTime(self.calculateSunset(position).getSunsetTime())
                        place.setPosition(position)
                        
                        crowdReport.setId(subJson["id"].string!)
                        NSLog("Report ID: \(subJson["id"].string!)")
                        //MARK: Loading CrowdReport Object
                        crowdReport.setTemperature(self.round(subJson["feel_avg"].string!))
                        crowdReport.setWeather(self.round(subJson["weather_avg"].string!))//rounding to integer values corresponding to weather icon scale (1-8)
                        //crowdReport.setWeatherIcon(UIImage(named: self.selectWeatherIcon(subJson["weather_avg"].string!, timeframe: "now"))!)
                        
                        //  NSLog("Report: Position: Region: \(place.getPosition().getRegion())")
                        //  NSLog("Report: Position: Country: \(place.getPosition().getCountry())")
                        //  NSLog("Report: Position: Lat: \(place.getPosition().getLatitude())")
                        //  NSLog("Report: Position: Lng: \(place.getPosition().getLongitude())")
                        
                        if (subJson["time_zone"].count == 0) {
                            crowdReport.setTimeZone("default")
                        } else {
                            crowdReport.setTimeZone(subJson["time_zone"].string!)
                        }
                        
                        if(place.getPosition().getLatitude() != "default" && place.getPosition().getLongitude() != "default"){
                            // let location = CLLocation.init(latitude: Double(place.getPosition().getLatitude())!, longitude: Double(place.getPosition().getLongitude())!)
                            crowdReport.setWeatherIcon(UIImage(named: self.selectWeatherIcon(crowdReport.getWeather(), timeframe: "now", position: position))!)
                        }
                        crowdReport.setWind(self.round(subJson["wind_avg"].string!)) //rounding to integer values corresponding to wind icon scale (1-5)
                        crowdReport.setWindIcon(UIImage(named: self.selectWindIcon(crowdReport.getWind()))!)
                        crowdReport.setPool(subJson["pool"].string!)
                        crowdReport.setTimestamp(subJson["time_calculated"].string!)
                        
                        //MARK: Finish loading Place Object
                        place.setCrowdReport(crowdReport)
                        crowdReportsForPlaces.append(place)
                    }//endFor
                    
                    NSLog("Loaded table: "+String(crowdReportsForPlaces))
                    completionHandler(crowdReports: crowdReportsForPlaces)
                    //          self.searchingForAvailablePlaces = false
                }//endIf
                
            }//endDoRequest2()
        }
    }//endGerReportsForPlaces2()
    
    func getCrowdPredictions(places:[Place], completionHandler: (crowdPredictions: Array<Place>) ->()){
        let url = "http://derecho.inf.usi.ch/Atmos/ios/get_crowd_predictions_ios.php"
        var jsonPlaces = Array<[String: AnyObject]>()
        var crowdPredictionsForPlaces = [Place]()
        for place in places {
            NSLog("Putting \(place.getName()) in JSON")
            let dictionary: [String:AnyObject]
            dictionary = ["place_name": place.getName(), "place_country": place.getCountry()]
            jsonPlaces.append(dictionary)
        }//endFor
        NSLog("\(places.count) JSONPlaces requesting weather updates: \(jsonPlaces) size: \(jsonPlaces.count)")
        if jsonPlaces.count > 0 {
            
            //doRequest(url, parameters: jsonPlaces)
            
            doRequest2(url, parameters: jsonPlaces) { (data) -> () in
                
                //      NSLog("Data returned: \(data)") // WORKS ;)
                //HERE you out code of what you want to happen when the task finishes
                let updatesJSON = data
                if updatesJSON.isEmpty == false {
                    for (_,subJson) in updatesJSON["weather"] {
                        NSLog("Looping over JSON")
                        let place = Place()
                        let crowdPrediction = CrowdPrediction()
                        let position = Position()
                        place.setName(subJson["place_name"].string!)
                        place.setCountry(subJson["place_country"].string!)
                        
                        //MARK: Loading Position Object
                        position.setRegion(place.getName())
                        position.setCountry(place.getCountry())
                        position.setLocalTimeZone(subJson["time_zone"].string!)
                        position.setLatitude(subJson["latitude"].string!)
                        position.setLongitude(subJson["longitude"].string!)
                        position.setSunriseTime(self.calculateSunrise(position).getSunriseTime())
                        position.setSunsetTime(self.calculateSunset(position).getSunsetTime())
                        place.setPosition(position)
                        
                        crowdPrediction.setId(subJson["id"].string!)
                        NSLog("Prediction ID: \(crowdPrediction.getId()) for \(place.getName())")
                        crowdPrediction.setTemperature(self.round(subJson["feel_avg"].string!))
                        crowdPrediction.setWeather(self.round(subJson["weather_avg"].string!))//rounding to integer values corresponding to weather icon scale (1-8)
                        if (subJson["time_zone"].count == 0) {
                            crowdPrediction.setTimeZone("default")
                        } else {
                            crowdPrediction.setTimeZone(subJson["time_zone"].string!)
                        }
                        
                        if(place.getPosition().getLatitude() != "default" && place.getPosition().getLongitude() != "default"){
                            NSLog("Position for Prediciton Not Default")
                            //let location = CLLocation.init(latitude: Double(place.getPosition().getLatitude())!, longitude: Double(place.getPosition().getLongitude())!)
                            //crowdPrediction.setWeatherIcon(UIImage(named: self.selectWeatherIcon(subJson["weather_avg"].string!, timeframe: "later"))!)
                            crowdPrediction.setWeatherIcon(UIImage(named: self.selectWeatherIcon(crowdPrediction.getWeather(), timeframe: "later", position: position))!)
                        }
                        crowdPrediction.setWind(self.round(subJson["wind_avg"].string!)) //rounding to integer values corresponding to wind icon scale (1-5)
                        crowdPrediction.setWindIcon(UIImage(named: self.selectWindIcon(crowdPrediction.getWind()))!)
                        
                        
                        crowdPrediction.setPool(subJson["pool"].string!)
                        crowdPrediction.setTimestamp(subJson["time_calculated"].string!)
                        place.setCrowdPrediction(crowdPrediction)
                        crowdPredictionsForPlaces.append(place)
                    }//endFor
                    
                    NSLog("Prediction Loaded table: "+String(crowdPredictionsForPlaces))
                    completionHandler(crowdPredictions: crowdPredictionsForPlaces)
                    //          self.searchingForAvailablePlaces = false
                }//endIf
                
            }//endDoRequest2()
        }
    }//endGerReportsForPlaces2()
    
    func uploadData(dataToUpload: Report, completionHandler: (status: String) -> ()){ //this is for uploading Reports, Predictions and Measurements
        let uploadUrl = "http://derecho.inf.usi.ch/Atmos/ios/upload_ios.php"
        var reportFlag = 0
        var predictionFlag = 0
        if (dataToUpload.getType() == "report"){
            reportFlag = 1
            predictionFlag = 0
        } else {
            reportFlag = 0
            predictionFlag = 1
        }
        
        
        connectToWeatherServer() {(deviceId) in
            NSLog("User ID returned: \(deviceId)")
            let dataJSON: Array<[String: AnyObject]> = [[
                //MARK: POSITION FIELDS
                "address" : dataToUpload.getPosition().getAddress(),
                "region" : dataToUpload.getPosition().getRegion(),
                "country" : dataToUpload.getPosition().getCountry(),
                "latitude" : dataToUpload.getPosition().getLatitude(),
                "longitude" : dataToUpload.getPosition().getLongitude(),
                "altitude" : dataToUpload.getPosition().getAltitude(),
                "accuracy" : dataToUpload.getPosition().getAccuracy(),
                "location_provider" : "GPS",
                "timestamp_location_local" : dataToUpload.getPosition().getLocalTimestamp(),
                "time_zone" : dataToUpload.getPosition().getLocalTimeZone(),
                "timestamp_location" : dataToUpload.getPosition().getServerTimestamp(),
                
                //MARK: MEASUREMENT FIELDS
                "device_id" : deviceId,
                "moisture" : "-999",
                "temperature": "-999",
                "pressure" : self.measurement.getPressure(),
                "illumination" : "-999",
                "magnetic_field" : self.measurement.getMagneticField(),
                "proximity" : "-999",
                "acceleration" : self.measurement.getAcceleration(),
                "duration" : "00:00:10",
                "timestamp_measurement_local" : self.measurement.getLocalTimestamp(),
                "timestamp_measurement" : self.measurement.getServerTimestamp(),
                "source" : "iPhone",
                
                //MARK: REPORT  FIELDS
                "report" : reportFlag, //flag indicates report if equals 1
                "input_1_report" : dataToUpload.getTemperature(),
                "input_2_report" : dataToUpload.getWeather(),
                "input_3_report" : dataToUpload.getWind(),
                "input_4_report" : "default",
                "timestamp_report_local" : dataToUpload.getPosition().getLocalTimestamp(),
                "timestamp_report" : dataToUpload.getPosition().getServerTimestamp(),
                
                //MARK: PREDICTION FIELDS
                "prediction" : predictionFlag, // flag indicates prediction if equals 1
                "input_1_prediction" : dataToUpload.getTemperature(),
                "input_2_prediction" : dataToUpload.getWeather(),
                "input_3_prediction" : dataToUpload.getWind(),
                "input_4_prediction" : "default",
                "timestamp_prediction_local" : dataToUpload.getPosition().getLocalTimestamp(),
                "timestamp_prediction" : dataToUpload.getPosition().getServerTimestamp()
                ]]
            self.doRequest2(uploadUrl, parameters: dataJSON, completionHandler: { (data) -> () in
                //   NSLog("Something returned here... \(data[0]["response"])")
                let response = String(data["response"]).stringByReplacingOccurrencesOfString("\"", withString: "")
                completionHandler(status: response)
            })
        }//endConnectToWeatherServer()
        
        
        
    }//endUploadData()
    
    func locateActualPosition(position: Position) -> Position {//this does reverse geolocation from lat and lng calling openstreetmaps.org API
        let lat: String! = String(location!.coordinate.latitude)
        let lng: String! = String(location!.coordinate.longitude)
        NSLog("Reverse Geolocating for --> Lat: \(lat) and Lng: \(lng)")
        if(self.isConnectedToNetwork() == true) {
            Alamofire.request(.GET, "http://nominatim.openstreetmap.org/reverse?format=json&lat=\(lat)&lon=\(lng)&zoom=18&addressdetails=1").responseJSON {response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /posts/1")
                    print(response.result.error!)
                    return
                }//endGuard()
                if let value: AnyObject = response.result.value {
                    var post: JSON = JSON(value)
                    // NSLog("*** POST REQUEST RETURNED: " + post.description) //reactivate for checking fetched JSON
                    NSLog("^^Reverse Geolocating place with ID: \(post["osm_id"]), address: \(post["address"]["suburb"]), region: \(post["address"]["town"]), country: \(post["address"]["country"])")
                    
                    if(post["address"]["suburb"].isEmpty){ //null checks in case API fails to return a full address
                        post["address"]["suburb"] = "unknown"
                    }
                    
                    if(post["address"]["town"].isEmpty){
                        post["address"]["town"] = "unknown"
                    }
                    
                    if(post["address"]["country"].isEmpty){
                        post["address"]["country"] = "unknown"
                    }
                    
                    position.setAddress(post["address"]["suburb"].string!)
                    position.setRegion(post["address"]["town"].string!)
                    position.setCountry(post["address"]["country"].string!)
                    position.setLatitude(lat)
                    position.setLongitude(lng)
                    position.setLocalTimestamp(self.getLocalTimestamp())
                    position.setServerTimestamp(self.convertTime("Europe/Zurich", date: NSDate()))
                    
                    position.setLocalTimeZone(NSTimeZone.localTimeZone().name)
                    position.setSunriseTime(self.calculateSunrise(position).getSunriseTime())
                    position.setSunsetTime(self.calculateSunset(position).getSunsetTime())
                }//endIf
            }//EndResponseIn()
        }
        else {
            
            NSLog("No Internet Connection available!")
        }
        return position
    }//endLocateActualPosition()
    
    func doRequest(url: String, parameters: Array<[String : AnyObject]>) -> JSON {
        var post: JSON = nil
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        mutableURLRequest.HTTPMethod = "POST"
        
        if let data = try! NSJSONSerialization.dataWithJSONObject(parameters, options:[]) as Optional {
            mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.HTTPBody = data
        } else {
            NSLog("Array Conversion to JSON failed...")
        }//endIf
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                // handle the results as JSON, without a bunch of nested if loops
                post = JSON(value)
                NSLog("*** POST REQUEST RETURNED: " + post.description)
                // NSLog("The key is: \(post["key"])")
            }//endIf
        }//endAlamofire
        return post
    }//endDoRequest()
    
    
    func doRequest2(url: String, parameters: Array<[String : AnyObject]>, completionHandler: (data: JSON) -> ()) {
        //        var completionHandler: UIBackgroundFetchResult
        NSLog("Parameters: \(parameters)")
        var post: JSON = nil
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        mutableURLRequest.HTTPMethod = "POST"
        
        if let data = try! NSJSONSerialization.dataWithJSONObject(parameters, options:[]) as Optional {
            mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.HTTPBody = data
        } else {
            NSLog("Array Conversion to JSON failed...")
        }//endIf
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                // handle the results as JSON, without a bunch of nested if loops
                post = JSON(value)
                completionHandler(data: post)
                // NSLog("*** POST REQUEST RETURNED: " + post.description)
                // NSLog("The key is: \(post["key"])")
            }//endIf
        }//endAlamofire
        
        //        return post
    }//endDoRequest()
    
    //MARK: Save and Load Data
    func savePlaces(places:[Place]){
        NSLog("Saving places table with size: \(places.count)")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(places, toFile: Place.ArchiveURL.path!)
        if !isSuccessfulSave {
            NSLog("Failed to save places...")
        } else {
            NSLog("Successfuly save places...")
        }
    }//endSavePlaces()
    
    func loadPlaces() -> [Place]? {
        var places = [Place]?()
        places = NSKeyedUnarchiver.unarchiveObjectWithFile(Place.ArchiveURL.path!) as?[Place]
        if places?.count > 0 {NSLog("Unarchiving Places[0]: \(places?[0].getName())")}
        return places
    }//endLoadPlaces()
    
    func selectWeatherIcon (weather: String, timeframe: String, position: Position!) -> String { //this returns the appropiate item depending on the weather state and hour of the day
        if(timeframe == "now"){
            if(isNight(0, position: position) == false) {
                switch(Int(weather)!-1) {//selecting adequate weather icon based on input from server by subtracting one to adapt to 0-7 scale
                case 0:
                    return "rain4"
                case 1:
                    return "rain2"
                case 2:
                    return "rain1"
                case 3:
                    return "sun_cloud4"
                case 4:
                    return "sun_cloud3"
                case 5:
                    return "sun_cloud2"
                case 6:
                    return "sun_cloud1"
                case 7:
                    return "sun_clear"
                default:
                    NSLog("Wrong number bar \(weather)")
                    return "no_data"
                }//endSwitch
            } else {
                switch(Int(weather)!-1) {
                case 0:
                    return "rain4"
                case 1:
                    return "rain2"
                case 2:
                    return "rain1"
                case 3:
                    return "moon_cloud4"
                case 4:
                    return "moon_cloud3"
                case 5:
                    return "moon_cloud2"
                case 6:
                    return "moon_cloud1"
                case 7:
                    return "moon_clear"
                default:
                    NSLog("Wrong number bar")
                    return "no_data"
                }//endSwitch
            }//endElse
        } else{
            if(isNight(3, position: position) == false) {
                switch(Int(weather)!-1) {//selecting adequate weather icon based on input from server by subtracting one to adapt to 0-7 scale
                case 0:
                    return "rain4"
                case 1:
                    return "rain2"
                case 2:
                    return "rain1"
                case 3:
                    return "sun_cloud4"
                case 4:
                    return "sun_cloud3"
                case 5:
                    return "sun_cloud2"
                case 6:
                    return "sun_cloud1"
                case 7:
                    return "sun_clear"
                default:
                    NSLog("Wrong number bar \(weather)")
                    return "no_data"
                }//endSwitch
            } else {
                switch(Int(weather)!-1) {
                case 0:
                    return "rain4"
                case 1:
                    return "rain2"
                case 2:
                    return "rain1"
                case 3:
                    return "moon_cloud4"
                case 4:
                    return "moon_cloud3"
                case 5:
                    return "moon_cloud2"
                case 6:
                    return "moon_cloud1"
                case 7:
                    return "moon_clear"
                default:
                    NSLog("Wrong number bar")
                    return "no_data"
                }//endSwitch
            }//endElse
        }//endElse
        
    }//endSelectWeatherIcon()
    
    
    func selectWeatherIconWhenNoLocation(weather: String)-> String {
        switch(Int(weather)!-1) {//selecting adequate weather icon based on input from server by subtracting one to adapt to 0-7 scale
        case 0:
            return "rain4"
        case 1:
            return "rain2"
        case 2:
            return "rain1"
        case 3:
            return "sun_cloud4"
        case 4:
            return "sun_cloud3"
        case 5:
            return "sun_cloud2"
        case 6:
            return "sun_cloud1"
        case 7:
            return "sun_clear"
        default:
            NSLog("Wrong number bar \(weather)")
            return "no_data"
        }//endSwitch
        
        
        
    }//endSelectWeatherIconNoLocation
    
    
    
    func selectWindIcon(wind: String) -> String { //selecting adequate wind icon based on input from server by subtracting one to adapt to 0-4 scale
        switch(Int(wind)!-1){
        case 0:
            return "wind1"
        case 1:
            return "wind2"
        case 2:
            return "wind3"
        case 3:
            return "wind4"
        case 4:
            return "wind5"
        default:
            NSLog("Wrong number bar")
            return "no_data"
        }//endSwitch
    }//endWind()

    
    func initializeAltimeter(){
        if CMAltimeter.isRelativeAltitudeAvailable() {
            print("Starting altimeter updates...")
            altimeter.startRelativeAltitudeUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { data, error in
                if (error == nil) {
                    //print("Relative Altitude: \(data!.relativeAltitude) m")
                    // print("Pressure: \(data!.pressure) hPa")
                    self.measurement.setPressure(String(data!.pressure))
                }//endIf
            })
            
        }
    }
    
    func initializeProximity(){
        let device = UIDevice.currentDevice()
        device.proximityMonitoringEnabled = true
        if device.proximityMonitoringEnabled {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "proximityChanged:", name: "UIDeviceProximityStateDidChangeNotification", object: device)
        }
    }
    
    func proximityChanged(notification: NSNotification) {
        if let device = notification.object as? UIDevice {
            NSLog("\(device) detected!")
        }
    }
    
    func initializeAccelerometer() {
        //Here we apply low pass filter on the acceleration values to exclude the effect of gravity on device's sensors
        //source: http://developer.android.com/reference/android/hardware/SensorEvent.html#values
        let alpha = 0.8 //// alpha is calculated as t / (t + dT)
        // with t, the low-pass filter's time-constant
        // and dT, the event delivery rate
        var gravX = 0.0
        var gravY = 0.0
        var gravZ = 0.0
        NSLog("--> Initializing accelerometer...")
        if(motionManager.accelerometerAvailable == true) {
            motionManager.accelerometerUpdateInterval = 0.2 // 200ms update interval to match the rate for android app (SENSOR_DELAY_NORMAL)
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
                data, error in
                // NSLog("Acceleration X: \(data?.acceleration.x)")
                //We first estimate gravity's influence
                gravX = alpha * gravX + (1 - alpha) * (data?.acceleration.x)!
                gravY = alpha * gravY + (1 - alpha) * (data?.acceleration.y)!
                gravZ = alpha * gravZ + (1 - alpha) * (data?.acceleration.z)!
                //removing gravity's effect from sensor inputs
                let linearAccelerationX = (data?.acceleration.x)! - gravX
                let linearAccelerationY = (data?.acceleration.y)! - gravY
                let linearAccelerationZ = (data?.acceleration.z)! - gravZ
                let overallAcceleration = sqrt(linearAccelerationX*linearAccelerationX + linearAccelerationY*linearAccelerationY + linearAccelerationZ*linearAccelerationZ)
                self.measurement.setAcceleration(String(overallAcceleration))
                // NSLog("Overall Acceleration: \(overallAcceleration)")
            }//endClosure
        }//endIf
    }//endInitializeAccelerometer()
    
    func initializeMagnetometer(){
        NSLog("--> Initializing magnetometer...")
        if(motionManager.magnetometerAvailable == true){
            motionManager.magnetometerUpdateInterval = 0.2 // 200ms update interval to match the rate for android app (SENSOR_DELAY_NORMAL)
            motionManager.startMagnetometerUpdates()
            motionManager.startMagnetometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
                data, error in
                //  NSLog("Magnetic field X: \(data?.magneticField.x)")
                //let overallMagneticField = sqrt(data?.magneticField.x*data?.magneticField.x + data?.magneticField.y*data?.magneticField.y + data.magneticField.z*data.magneticField.z)
                let magneticFieldX = data?.magneticField.x
                let magneticFieldY = data?.magneticField.y
                let magneticFieldZ = data?.magneticField.z
                
                let overallMagneticField = sqrt(magneticFieldX!*magneticFieldX! + magneticFieldY!*magneticFieldY! + magneticFieldZ!*magneticFieldZ!)
                // NSLog("Overall Magnetic Field: \(overallMagneticField)")
                self.measurement.setMagneticField(String(overallMagneticField))
            }//endClosure
        }//endIf
        
    }
    func round(number: String) -> String {
        let result = String(format: "%.0f", Double(number)!)
        NSLog("Result: \(result)")
        return result
    }//endRound()
    
    func hasLocationPermissions() -> Bool {//this function simply returns true/false if the app has/doesnt have location permission access
        switch (CLLocationManager.authorizationStatus()){
        case .AuthorizedAlways:
            //  NSLog("Location Authorized always")
            return true
        case .Denied:
            NSLog("Location Denied")
            // initialized = false
            return false
        case .NotDetermined:
            //  NSLog("Location not detemined")
            return false
        case .Restricted:
            //  NSLog("Location restricted")
            return false
        default:
            //   NSLog("Location access allowed as default")
            return true
        }//endSwitch()
    }//endHasLocationPermissions()
    
    func locationAvailable() -> Bool{//this function returns true/false when the app has/doesnt have receive at least a location update
        // NSLog("Location manager initialized: \(initialized)")
        if(CLLocationManager.locationServicesEnabled() == true && initialized == true){
            switch (CLLocationManager.authorizationStatus()){
            case .AuthorizedAlways:
                //  NSLog("Location Authorized always")
                return true
            case .Denied:
                NSLog("Location Denied")
                // initialized = false
                return false
            case .NotDetermined:
                //  NSLog("Location not detemined")
                return false
            case .Restricted:
                //  NSLog("Location restricted")
                return false
            default:
                //   NSLog("Location access allowed as default")
                return true
            }//endSwitch()
        } else {
            NSLog("Location services off")
            return false
        }//endElse
    }//endLocationAvailable()
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }//endIsConnectedToNetwork()
    
}//endClass


let SharedToolbox = Toolbox()
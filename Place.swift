//
//  Place.swift
//  Atmos
//
//  Created by Evangelos on 02/01/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//

import UIKit

public class Place: NSObject, NSCoding {
    //MARK Properties
    private var name: String
    private var country: String
    private var timestamp: String
    private var crowdReport: CrowdReport
    private var crowdPrediction: CrowdPrediction
    private var position: Position
    //MARK: Archiving Paths
    //Creating a file path to data saved in a persistent way
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("places")
    
    //MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let countryKey = "country"
        static let timestampKey = "timestamp"
        
        //MARK: CrowdReport Property Keys
        static let crIdKey = "crId"
        static let crTypeKey="crType"
        static let crTemperatureKey = "crTemperature"
        static let crWeatherKey = "crWeather"
        static let crWindKey = "crWind"
        static let crHumidityKey = "crHumidity"
        static let crWeatherIconKey = "crWeatherIcon"
        static let crWindIconKey = "crWindIcon"
        static let crPoolKey = "crPool"
        static let crTimestampKey = "crTimestamp"
        static let crTimeZoneKey = "crTimeZone"
        static let crFeelTextKey = "crFeelText"
        static let crHumidityTextKey = "crHumidityText"
        static let crProgressVisibleKey = "crProgressVisible"
        
        //MARK: CrowdPrediction Property Keys
        static let cpIdKey = "cpId"
        static let cpTypeKey="cpType"
        static let cpTemperatureKey = "cpTemperature"
        static let cpWeatherKey = "cpWeather"
        static let cpWindKey = "cpWind"
        static let cpHumidityKey = "cpHumidity"
        static let cpWeatherIconKey = "cpWeatherIcon"
        static let cpWindIconKey = "cpWindIcon"
        static let cpPoolKey = "cpPool"
        static let cpTimestampKey = "cpTimestamp"
        static let cpTimeZoneKey = "cpTimeZone"
        static let cpFeelTextKey = "cpFeelText"
        static let cpHumidityTextKey = "cpHumidityText"
        static let cpProgressVisibleKey = "cpProgressVisible"

        //MARK: Position Property Keys
        static let addressKey = "address"
        static let latitudeKey = "latitude"
        static let longitudeKey = "longitude"
        static let altitudeKey = "altitude"
        static let accuracyKey = "accuracy"
        static let localTimeZoneKey = "localTimeZone"
        static let localTimestampKey = "localTimestamp"
        static let serverTimestampKey = "serverTimestamp"
        static let sunriseKey = "sunrise"
        static let sunsetKey = "sunset"
    }//endPropertyKey
    
    //MARK: Initialization
    /*
    init(name: String, countryName: String, temperature: Double, crowdNumber: Int, weatherIcon: UIImage?){
        self.name = name
        self.coutryName = countryName
        self.temperature = temperature
        self.crowdNumber = crowdNumber
        self.weatherIcon = weatherIcon
   }//endInitilization()
    */
    
    public func encodeWithCoder(aCoder: NSCoder) {
        //MARK: encoding Place's fields
        //aCoder.encodeObject(String(name), forKey: PropertyKey.nameKey)
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(country, forKey: PropertyKey.countryKey)
        aCoder.encodeObject(timestamp, forKey: PropertyKey.timestampKey)
       
        NSLog("--Encoding Place.name: \(name)")

        //MARK: encoding CrowdReport's fields
        aCoder.encodeObject(crowdReport.getId(), forKey: PropertyKey.crIdKey)
        aCoder.encodeObject(crowdReport.getType(), forKey: PropertyKey.crTypeKey)
        aCoder.encodeObject(crowdReport.getTemperature(), forKey: PropertyKey.crTemperatureKey)
        aCoder.encodeObject(crowdReport.getWeather(), forKey: PropertyKey.crWeatherKey)
        aCoder.encodeObject(crowdReport.getWind(), forKey: PropertyKey.crWindKey)
        aCoder.encodeObject(crowdReport.getHumidity(), forKey: PropertyKey.crHumidityKey)
        aCoder.encodeObject(crowdReport.getWeatherIcon(), forKey: PropertyKey.crWeatherIconKey)
        aCoder.encodeObject(crowdReport.getWindIcon(), forKey: PropertyKey.crWindIconKey)
        aCoder.encodeObject(crowdReport.getPool(), forKey: PropertyKey.crPoolKey)
        aCoder.encodeObject(crowdReport.getTimestamp(), forKey: PropertyKey.crTimestampKey)
        aCoder.encodeObject(crowdReport.getTimeZone(), forKey: PropertyKey.crTimeZoneKey)
        aCoder.encodeObject(crowdReport.getFeelText(), forKey: PropertyKey.crFeelTextKey)
        aCoder.encodeObject(crowdReport.getHumidityText(), forKey: PropertyKey.crHumidityTextKey)
        aCoder.encodeObject(crowdReport.getProgressVisible(), forKey: PropertyKey.crProgressVisibleKey)
        
        //MARK: encoding CrowdPrediction's fields
        aCoder.encodeObject(crowdPrediction.getId(), forKey: PropertyKey.cpIdKey)
        aCoder.encodeObject(crowdPrediction.getType(), forKey: PropertyKey.cpTypeKey)
        aCoder.encodeObject(crowdPrediction.getTemperature(), forKey: PropertyKey.cpTemperatureKey)
        aCoder.encodeObject(crowdPrediction.getWeather(), forKey: PropertyKey.cpWeatherKey)
        aCoder.encodeObject(crowdPrediction.getWind(), forKey: PropertyKey.cpWindKey)
        aCoder.encodeObject(crowdPrediction.getHumidity(), forKey: PropertyKey.cpHumidityKey)
        aCoder.encodeObject(crowdPrediction.getWeatherIcon(), forKey: PropertyKey.cpWeatherIconKey)
        aCoder.encodeObject(crowdPrediction.getWindIcon(), forKey: PropertyKey.cpWindIconKey)
        aCoder.encodeObject(crowdPrediction.getPool(), forKey: PropertyKey.cpPoolKey)
        aCoder.encodeObject(crowdPrediction.getTimestamp(), forKey: PropertyKey.cpTimestampKey)
        aCoder.encodeObject(crowdPrediction.getTimeZone(), forKey: PropertyKey.cpTimeZoneKey)
        aCoder.encodeObject(crowdPrediction.getFeelText(), forKey: PropertyKey.cpFeelTextKey)
        aCoder.encodeObject(crowdPrediction.getHumidityText(), forKey: PropertyKey.cpHumidityTextKey)
        aCoder.encodeObject(crowdPrediction.getProgressVisible(), forKey: PropertyKey.cpProgressVisibleKey)
        
        
        //MARK: encoding Position's fields
        aCoder.encodeObject(position.getAddress(), forKey: PropertyKey.addressKey)
        aCoder.encodeObject(position.getLatitude(), forKey: PropertyKey.latitudeKey)
        aCoder.encodeObject(position.getLongitude(), forKey: PropertyKey.longitudeKey)
        aCoder.encodeObject(position.getAltitude(), forKey: PropertyKey.altitudeKey)
        aCoder.encodeObject(position.getAccuracy(), forKey: PropertyKey.accuracyKey)
        aCoder.encodeObject(position.getLocalTimeZone(), forKey: PropertyKey.localTimeZoneKey)
        aCoder.encodeObject(position.getLocalTimestamp(), forKey:  PropertyKey.localTimestampKey)
        aCoder.encodeObject(position.getServerTimestamp(), forKey: PropertyKey.serverTimestampKey)
        aCoder.encodeObject(position.getSunriseTime(), forKey: PropertyKey.sunriseKey)
        aCoder.encodeObject(position.getSunsetTime(), forKey: PropertyKey.sunsetKey)
    }//endEncodeWithCoder()
    
    required convenience public init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let country = aDecoder.decodeObjectForKey(PropertyKey.countryKey) as! String
        let timestamp = aDecoder.decodeObjectForKey(PropertyKey.timestampKey) as! String

        //Decoding and assembling crowdReport object
        let crId = aDecoder.decodeObjectForKey(PropertyKey.crIdKey) as! String
        let crType = aDecoder.decodeObjectForKey(PropertyKey.crTypeKey) as! String
        let crTemperature = aDecoder.decodeObjectForKey(PropertyKey.crTemperatureKey) as! String
        let crWeather = aDecoder.decodeObjectForKey(PropertyKey.crWeatherKey) as! String
        let crWind = aDecoder.decodeObjectForKey(PropertyKey.crWindKey) as! String
        let crHumidity = aDecoder.decodeObjectForKey(PropertyKey.crHumidityKey) as! String
        let crWeatherIcon = aDecoder.decodeObjectForKey(PropertyKey.crWeatherIconKey) as! UIImage
        let crWindIcon = aDecoder.decodeObjectForKey(PropertyKey.crWindIconKey) as! UIImage
        let crPool = aDecoder.decodeObjectForKey(PropertyKey.crPoolKey) as! String
        let crTimestamp = aDecoder.decodeObjectForKey(PropertyKey.crTimestampKey) as! String
        let crTimeZone = aDecoder.decodeObjectForKey(PropertyKey.crTimeZoneKey) as! String
        let crFeelText = aDecoder.decodeObjectForKey(PropertyKey.crFeelTextKey) as! String
        let crHumidityText = aDecoder.decodeObjectForKey(PropertyKey.crHumidityKey) as! String
        let crProgressVisible = aDecoder.decodeObjectForKey(PropertyKey.crProgressVisibleKey) as! Bool
        let crowdReport = CrowdReport(id: crId, type: crType, temperature: crTemperature, weather: crWeather, wind: crWind, humidity: crHumidity, weatherIcon: crWeatherIcon, windIcon: crWindIcon, pool: crPool, timestamp: crTimestamp, timeZone: crTimeZone, feelText: crFeelText, humidityText: crHumidityText, progressVisible: crProgressVisible)

        //Decoding and assembling crowdPrediction object
        let cpId = aDecoder.decodeObjectForKey(PropertyKey.cpIdKey) as! String
        let cpType = aDecoder.decodeObjectForKey(PropertyKey.cpTypeKey) as! String
        let cpTemperature = aDecoder.decodeObjectForKey(PropertyKey.cpTemperatureKey) as! String
        let cpWeather = aDecoder.decodeObjectForKey(PropertyKey.cpWeatherKey) as! String
        let cpWind = aDecoder.decodeObjectForKey(PropertyKey.cpWindKey) as! String
        let cpHumidity = aDecoder.decodeObjectForKey(PropertyKey.cpHumidityKey) as! String
        let cpWeatherIcon = aDecoder.decodeObjectForKey(PropertyKey.cpWeatherIconKey) as! UIImage
        let cpWindIcon = aDecoder.decodeObjectForKey(PropertyKey.cpWindIconKey) as! UIImage
        let cpPool = aDecoder.decodeObjectForKey(PropertyKey.cpPoolKey) as! String
        let cpTimestamp = aDecoder.decodeObjectForKey(PropertyKey.cpTimestampKey) as! String
        let cpTimeZone = aDecoder.decodeObjectForKey(PropertyKey.cpTimeZoneKey) as! String
        let cpFeelText = aDecoder.decodeObjectForKey(PropertyKey.cpFeelTextKey) as! String
        let cpHumidityText = aDecoder.decodeObjectForKey(PropertyKey.cpHumidityKey) as! String
        let cpProgressVisible = aDecoder.decodeObjectForKey(PropertyKey.cpProgressVisibleKey) as! Bool
        let crowdPrediction = CrowdPrediction(id: cpId, type: cpType, temperature: cpTemperature, weather: cpWeather, wind: cpWind, humidity: cpHumidity, weatherIcon: cpWeatherIcon, windIcon: cpWindIcon, pool: cpPool, timestamp: cpTimestamp, timeZone: cpTimeZone, feelText: cpFeelText, humidityText: cpHumidityText, progressVisible: cpProgressVisible)

        //Decoding and assembling Position object
        let address = aDecoder.decodeObjectForKey(PropertyKey.addressKey) as! String
        let latitude = aDecoder.decodeObjectForKey(PropertyKey.latitudeKey) as! String
        let longitude = aDecoder.decodeObjectForKey(PropertyKey.longitudeKey) as! String
        let altitude = aDecoder.decodeObjectForKey(PropertyKey.altitudeKey) as! String
        let accuracy = aDecoder.decodeObjectForKey(PropertyKey.accuracyKey) as! String
        let localTimeZone = aDecoder.decodeObjectForKey(PropertyKey.localTimeZoneKey) as! String
        let localTimestamp = aDecoder.decodeObjectForKey(PropertyKey.localTimestampKey) as! String
        let serverTimestamp = aDecoder.decodeObjectForKey(PropertyKey.serverTimestampKey) as! String
        let sunriseTime = aDecoder.decodeObjectForKey(PropertyKey.sunriseKey) as! String
        let sunsetTime = aDecoder.decodeObjectForKey(PropertyKey.sunsetKey) as! String

        let position = Position(address: address, region: name, country: country, latitude: latitude, longitude: longitude, altitude: altitude, accuracy: accuracy, localTimestamp: localTimestamp, serverTimestamp: serverTimestamp, localTimeZone: localTimeZone, sunrise: sunriseTime, sunset: sunsetTime)
        
        self.init(name: name, country: country, timestamp: timestamp, crowdReport: crowdReport!, crowdPrediction: crowdPrediction!, position: position!)
    }//endRequiredConvenienceInit()
    
    init!(name: String, country: String, timestamp: String, crowdReport: CrowdReport, crowdPrediction: CrowdPrediction, position: Position){
        self.name = name
        NSLog("Self init with name: \(name)")
        self.country = country
        self.timestamp = timestamp
        self.crowdReport = crowdReport
        self.crowdPrediction = crowdPrediction
        self.position = position
        super.init()
    }//endInit?()
    
    override init(){
        name = "default"
        country = "default"
        crowdReport = CrowdReport()
        crowdPrediction = CrowdPrediction()
        position = Position()
        timestamp = "default"
    }//endInit()
    
    //MARK: Setters
    public func setName(_name: String) {
        name = _name
    }
    public func setCountry(_country: String) {
        country = _country
    }
    public func setTimestamp(_timestamp: String) {
        timestamp = _timestamp
    }
    public func setCrowdReport(_crowdReport: CrowdReport) {
        crowdReport = _crowdReport
    }
    public func setCrowdPrediction(_crowdPrediction: CrowdPrediction) {
        crowdPrediction = _crowdPrediction
    }
    public func setPosition(_position: Position) {
        position = _position
    }
    
    //MARK: Getters
    public func getName() -> String {
        return name
    }
    
    public func getCountry() -> String {
        return country
    }
    
    public func getCrowdReport() -> CrowdReport {
        return crowdReport
    }
    
    public func getCrowdPrediction() -> CrowdPrediction {
        return crowdPrediction
    }
    public func getPosition() -> Position {
        return position
    }
}//endClassPlace

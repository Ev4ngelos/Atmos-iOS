//
//  Position.swift
//  Atmos
//
//  Created by Evangelos on 17/01/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
public class Position {
    //MARK: Properties
    private var address : String
    private var region : String
    private var country : String
    private var latitude: String
    private var longitude: String
    private var altitude: String
    private var accuracy: String
    private var localTimestamp: String //local time recorded
    private var serverTimestamp: String //server time recorded
    private var localTimeZone: String
    private var sunriseTime: String
    private var sunsetTime: String

    public init() {
        address = "default"
        region = "default"
        country = "default"
        latitude = "default"
        longitude = "default"
        altitude = "default"
        accuracy = "default"
        localTimestamp = "default"
        serverTimestamp = "default"
        localTimeZone = "default"
        sunriseTime = "default"
        sunsetTime = "default"
        //super.init()
    }
    public init?(address: String, region: String, country: String, latitude: String, longitude: String, altitude: String, accuracy: String, localTimestamp: String, serverTimestamp: String, localTimeZone: String, sunrise: String, sunset: String){
        self.address = address
        self.region = region
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.accuracy = accuracy
        self.localTimestamp = localTimestamp
        self.localTimeZone = localTimeZone
        self.serverTimestamp = serverTimestamp
        self.sunriseTime = sunrise
        self.sunsetTime = sunset
    }
    //MARK: Setters
    public func setAddress(_address: String) {
        address = _address
    }
    
    public func setRegion(_region: String) {
        region = _region
    }
    
    public func setCountry(_country: String){
        country = _country
    }
    
    public func setLatitude(_lat: String){
        latitude = _lat
    }
    
    public func setLongitude(_lng: String) {
        longitude = _lng
    }
   
    
    public func setLocalTimestamp(_localTimestamp: String){
        localTimestamp = _localTimestamp
    }
    
    public func setServerTimestamp(_serverTimestamp: String) {
        serverTimestamp = _serverTimestamp
    }
    public func setLocalTimeZone(_localTimeZone: String) {
        localTimeZone = _localTimeZone
    }
    
    public func setSunriseTime(_sunrise: String) {
        sunriseTime = _sunrise
    }
    
    public func setSunsetTime(_sunset: String) {
        sunsetTime = _sunset
    }
    
    public func setAltitude(_altitude: String) {
        altitude = _altitude
    }
    
    public func setAccuracy(_accuracy: String) {
        accuracy = _accuracy
    }
    
    //MARK : Getters
    public func getAddress() ->String {
        return address
    }
    
    public func getRegion() ->String {
        return region
    }
    
    public func getCountry() ->String {
        return country
    }
    
    public func getLatitude() ->String {
        return latitude
    }
    
    public func getLongitude() ->String {
        return longitude
    }
 
    public func getLocalTimestamp() ->String {
        return localTimestamp
    }
    
    public func getServerTimestamp() -> String {
        return serverTimestamp
    }
    
    public func getLocalTimeZone() ->String {
        return localTimeZone
    }
    
    public func getSunriseTime() -> String {
        return sunriseTime
    }
    
    public func getSunsetTime() -> String {
        return sunsetTime
    }
    
    public func getAltitude() -> String {
        return altitude
    }
    
    public func getAccuracy() -> String {
        return accuracy
    }
    
    public func getSunriseNSDate() -> NSDate {
        var sunrise = NSDate()
        if (localTimeZone != "default" && sunriseTime != "default") {
            let mydateFormatter = NSDateFormatter()
            mydateFormatter.calendar = NSCalendar(calendarIdentifier: "NSCalendarIdentifierISO8601")
            mydateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            mydateFormatter.timeZone = NSTimeZone(abbreviation: "GMT");
            sunrise = mydateFormatter.dateFromString(getSunriseTime())!
        }
        return sunrise
    }
    
    public func getSunsetNSDate() -> NSDate {
        var sunset = NSDate()
        if (localTimeZone != "default" && sunsetTime != "default") {
            let mydateFormatter = NSDateFormatter()
            mydateFormatter.calendar = NSCalendar(calendarIdentifier: "NSCalendarIdentifierISO8601")
            mydateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            mydateFormatter.timeZone = NSTimeZone(abbreviation: "GMT");
            sunset = mydateFormatter.dateFromString(getSunsetTime())!
        }
        return sunset
    }
    
    public func getSunriseNSDate2() -> NSDate {
        let mydateFormatter = NSDateFormatter()
        mydateFormatter.calendar = NSCalendar(calendarIdentifier: "NSCalendarIdentifierISO8601")
        mydateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        mydateFormatter.timeZone = NSTimeZone(abbreviation: "GMT");
        return mydateFormatter.dateFromString(getSunriseTime())!
    }
}//endPosition.class
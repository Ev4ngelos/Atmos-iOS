//
//  CrowdReport.swift
//  Atmos
//
//  Created by Evangelos on 24/01/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//

import UIKit

public class CrowdReport {
    //MARK : Properties
    
    var id: String
    var type: String
    var temperature: String
    var weather: String
    var wind: String
    var humidity: String
    var weatherIcon: UIImage!
    var windIcon: UIImage!
    var pool: String
    var timestamp: String
    var timeZone: String
    var feelText: String//description in qualitative terms
    var humidityText: String
    var progressVisible: Bool;
    
    
    init(){
        let defaultIcon = UIImage(named: "no_data")
        id = "-1"
        type = "crowdReport"
        temperature = "default"
        weather = "default"
        wind = "default"
        humidity = "default"
        weatherIcon = defaultIcon//setting default icon: no data
        windIcon = defaultIcon//setting defaukt icon: no data
        pool = "default"
        timestamp = "default"
        timeZone = "default"
        feelText = "default"
        humidityText = "default"
        progressVisible = true
        //super.init()
    }//endInit()

    public init?(id: String, type: String, temperature: String, weather: String, wind: String, humidity: String, weatherIcon: UIImage?, windIcon: UIImage?, pool: String, timestamp: String, timeZone: String, feelText: String, humidityText: String, progressVisible: Bool) {
      //  super.init()
        self.id = id
        self.type = type
        self.temperature = temperature
        self.weather = weather
        self.wind = wind
        self.humidity = humidity
        self.weatherIcon = weatherIcon
        self.windIcon = windIcon
        self.pool = pool
        self.timestamp = timestamp
        self.timeZone = timeZone
        self.feelText = feelText
        self.humidityText = humidityText
        self.progressVisible = progressVisible
        
    }

    
    
    //MARK: Setters
    
    public func setId(_id: String){
        id = _id
    }

    public func setType(_type: String) {
        type = _type
    }
    public func setTemperature(_temperature: String) {
        temperature = _temperature
    }
    
    public func setWeather(_weather: String) {
        weather = _weather
    }
    public func setWind(_wind: String) {
        wind = _wind
    }
    
    public func setHumidity(_humidity: String) {
        humidity = _humidity
    }
    
    public func setWeatherIcon(_weatherIcon: UIImage) {
        weatherIcon = _weatherIcon
    }
    
    public func setWindIcon(_windIcon: UIImage) {
        windIcon = _windIcon
    }
    
    public func setPool(_pool: String) {
        pool = _pool
    }
    
    public func setTimestamp(_timestamp: String) {
        timestamp = _timestamp
    }
    
    public func setTimeZone(_timeZone: String) {
        timeZone = _timeZone
    }
    
    public func setFeelText(_feelText: String) {
        feelText = _feelText
    }
    
    public func setHumidityText(_humidityText: String) {
        humidityText = _humidityText
    }
    
    public func setProgressVisible(_progressVisible: Bool) {
        progressVisible = _progressVisible
    }
    
    //MARK : Getters
    
    public func getId() -> String {
        return id
    }
    
    public func getType() -> String {
        return type
    }
    
    public func getTemperature() -> String {
        return temperature
    }
    
    public func getWeather() -> String {
        return weather
    }
    
    public func getWind() -> String {
        return wind
    }
    
    public func getHumidity() -> String {
        return humidity
    }
    
    public func getWeatherIcon() -> UIImage {
        return weatherIcon
    }
    
    public func getWindIcon() -> UIImage {
        return windIcon
    }
    
    public func getPool() -> String {
        return pool
    }
    
    public func getTimestamp() -> String {
        return timestamp
    }
    
    public func getTimeZone() -> String {
        return timeZone
    }
    
    public func getFeelText() -> String {
        return feelText
    }
    
    public func getHumidityText() -> String {
        return humidityText
    }
    
    public func getProgressVisible() ->Bool {
        return progressVisible
    }
}//endCrowdReport.swift

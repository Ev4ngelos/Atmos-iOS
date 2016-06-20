//
//  CrowdPrediction.swift
//  Atmos
//
//  Created by Evangelos on 24/01/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//

import UIKit

public class CrowdPrediction: CrowdReport {
    
    
    override init() {
        super.init()
        setType("crowdPrediction")
        
        
    }
    override init?(id: String, type: String, temperature: String, weather: String, wind: String, humidity: String, weatherIcon: UIImage?, windIcon: UIImage?, pool: String, timestamp: String, timeZone: String, feelText: String, humidityText: String, progressVisible: Bool) {
        super.init()
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
  
    
}



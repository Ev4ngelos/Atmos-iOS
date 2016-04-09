//
//  Position.swift
//  Atmos
//
//  Created by Evangelos on 17/01/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//

import Foundation

public class Report {
    //MARK Properties
    private var type: String //report OR prediction
    private var userId:String //userId on Atmos remote DB
    private var temperature: String // temp
    private var weather: String // weather
    private var wind: String //wind
    private var position: Position

    public init(){
        type = "report"
        userId = "default"
        temperature = "default"
        weather = "default"
        wind = "default"
        position = Position()
    }//endInit()

    //MARK: Setters
    public func setType(_type: String) {
        type = _type
    
    }
    
    public func setUserId(_userId: String) {
        userId = _userId
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
    
    public func setPosition(_position: Position) {
        position = _position
    }
    
    //MARK: Getters
    public func getType() -> String {
        return type
    }
    public func getUserId() -> String {
        return userId
    }
    
    public func getTemperature() -> String {
        return temperature
    }
    
    public func getWeather() ->String {
        return weather
    }
    
    public func getWind() -> String {
        return wind
    }
    
    public func getPosition() -> Position {
        return position
    }
}//endPosition.swift
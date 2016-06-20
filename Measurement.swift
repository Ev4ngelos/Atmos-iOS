//
//  Measurement.swift
//  Atmos
//
//  Created by Evangelos on 17/01/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//

import Foundation

public class Measurement { //setting class properties as private we restrict access only by method calls and thus it's safer
    //MARK: Properties
    private var userId: String
    private var type: String
    private var moisture: String
    private var temperature: String
    private var pressure: String
    private var illumination: String
    private var magneticField: String
    private var proximity: String
    private var acceleration: String
    private var position: Position
    private var duration: String
    private var localTimestamp: String
    private var serverTimestamp: String
    private var source: String
    
    init() {
        userId = "default"
        type = "measurement"
        moisture = "default"
        temperature = "default"
        pressure = "default"
        illumination = "default"
        magneticField = "default"
        proximity = "default"
        acceleration = "default"
        position = Position()
        duration = "default"
        localTimestamp = "default"
        serverTimestamp = "default"
        source = "default"
        //super.init()
    }//endInit()
    
    //MARK: Setters
    
    public func setUserId(_userId: String){
        userId = _userId
    }
    
    public func setType(_type: String) {
        type = _type
    }

    public func setMoisture(_moisture: String) {
        moisture = _moisture
    }
    
    public func setTemperature(_temperature: String) {
        temperature = _temperature
    }
    
    public func setPressure(_pressure: String) {
        pressure = _pressure
    }
    
    public func setIllumination(_illumination: String) {
        illumination = _illumination
    }
    
    public func setMagneticField(_magneticField: String) {
        magneticField = _magneticField
    }
    
    public func setProximity(_proximity: String) {
        proximity = _proximity
    }
    
    public func setAcceleration(_acceleration: String) {
        acceleration = _acceleration
    }
    
    public func setPosition(_position: Position) {
        position = _position
    }
    
    public func setDuration(_duration: String) {
        duration = _duration
    }
    
    public func setLocalTimestamp(_localTimestamp: String) {
        localTimestamp = _localTimestamp
    }
    
    public func setServerTimestamp(_serverTimestamp: String) {
        serverTimestamp = _serverTimestamp
    }
    
    public func setSource(_source: String) {
        source = _source
    }
    //MARK: Getters
    
    public func getUserId() -> String {
        return userId
    }
    
    public func getType() -> String {
        return type
    }
    
    public func getMoisture() -> String {
        return moisture
    }
    
    public func getTemperature() -> String {
        return temperature
    }
    
    public func getPressure() -> String {
        return pressure
    }
    
    public func getIllumination() -> String {
        return illumination
    }
    
    public func getMagneticField() -> String {
        return magneticField
    }
    
    public func getProximity() -> String {
        return proximity
    }
    
    public func getAcceleration() -> String {
        return acceleration
    }
    
    public func getPosition() -> Position {
        return position
    }
    
    public func getDuration() -> String {
        return duration
    }
    
    public func getLocalTimestamp() -> String {
        return localTimestamp
    }

    public func getServerTimestamp() -> String {
        return serverTimestamp
    }
    
    public func getSource() -> String {
        return source
    }
}//endMeasurement.swift
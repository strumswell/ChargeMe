//
//  batteryAPI.swift
//  ChargeMe
//
//  Created by Philipp Bolte on 25.06.18.
//  Copyright © 2018 Philipp Bolte. All rights reserved.
//

import Cocoa
import CoreFoundation
import IOKit.ps

class BatteryAPI: NSObject {
    
    func getPowerSourceInfo() -> [String: AnyObject] {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        var desc = [String: AnyObject]()
        
        for ps in sources {
            desc = IOPSGetPowerSourceDescription(snapshot, ps).takeUnretainedValue() as! [String: AnyObject]
        }
        return desc
    }
    
    func getBatteryLevel() -> Int{
        return (getPowerSourceInfo()[kIOPSCurrentCapacityKey] as? Int)!
    }
    
    func getBatteryHealth() -> String{
        return (getPowerSourceInfo()[kIOPSBatteryHealthKey] as? String)!
    }
    
    func getRemainingTime() -> Double{
        return round(100 * (getPowerSourceInfo()[kIOPSTimeToEmptyKey] as? Double)!/60) / 100
    }
    
    func getRemainingTimeText() -> String{
        if isCharging() {
            return "Charging..."
        } else if getRemainingTime() < 0 {
           return "Calculating..."
        } else {
            return String(getRemainingTime())
        }
    }
    
    func isCharging() -> BooleanLiteralType{
        return (getPowerSourceInfo()[kIOPSIsChargingKey] as? BooleanLiteralType)!
    }
}

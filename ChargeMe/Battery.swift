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

class Battery: NSObject {
    
    func getPowerSourceInfo() -> [String: AnyObject] {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        var desc = [String: AnyObject]()
        
        for ps in sources {
            desc = IOPSGetPowerSourceDescription(snapshot, ps).takeUnretainedValue() as! [String: AnyObject]
        }
        return desc
    }
    
    func getBatteryLevel() -> Int {
        return (getPowerSourceInfo()[kIOPSCurrentCapacityKey] as? Int)!
    }
    
    //Someone out there knowing possible health values beside 'Good'? -> Github issue
    func getBatteryHealth() -> String {
        let health = getPowerSourceInfo()[kIOPSBatteryHealthKey] as? String
        if health == "Good" {
            return NSLocalizedString("Good", comment: "Good battery health")
        } else {
            return health!
        }
    }
    
    func getRemainingTime() -> Double {
        return round(100 * (getPowerSourceInfo()[kIOPSTimeToEmptyKey] as? Double)!/60) / 100
    }
    
    func getRemainingTimeText() -> String {
        if isCharging() || isFull() {
            return NSLocalizedString("Charging...", comment: "Indicating that battery is charging")
        } else if getRemainingTime() < 0 {
           return NSLocalizedString("Calculating...", comment: "Indicating battery usage calculation")
        } else {
            return String(getRemainingTime())+"h"
        }
    }
    
    func isCharging() -> BooleanLiteralType {
        return (getPowerSourceInfo()[kIOPSIsChargingKey] as? BooleanLiteralType)!
    }
    
    func isFull() -> BooleanLiteralType {
        if (getPowerSourceInfo()[kIOPSIsChargedKey] as? BooleanLiteralType) != nil {
            return (getPowerSourceInfo()[kIOPSIsChargedKey] as? BooleanLiteralType)!
        } else {
            return false
        }
    }
    
}

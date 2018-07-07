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
    /**
     * Get information about power source
     *
     * - Returns: String array containing all information about power source
     */
    func getPowerSourceInfo() -> [String: AnyObject] {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        var desc = [String: AnyObject]()
        
        for ps in sources {
            desc = IOPSGetPowerSourceDescription(snapshot, ps).takeUnretainedValue() as! [String: AnyObject]
        }
        return desc
    }
    
    /**
     * Get battery percentage level
     *
     * - Returns: Battery level
     */
    func getBatteryLevel() -> Int {
        return (getPowerSourceInfo()[kIOPSCurrentCapacityKey] as? Int)!
    }
    
    /**
     * Get information about battery health
     *
     * - Returns: Battery health
     */
    func getBatteryHealth() -> String {
        let health = getPowerSourceInfo()[kIOPSBatteryHealthKey] as? String
        if health == "Good" {
            return NSLocalizedString("Good", comment: "Good battery health")
        } else {
            return health!
        }
    }
    
    /**
     * Get information about remaining time on charge
     *
     * - Returns: Remaining time in minutes
     */
    func getRemainingTime() -> Int {
        return (getPowerSourceInfo()[kIOPSTimeToEmptyKey] as? Int)!
    }
    
    /**
     * Get string for remaining time text in menu bar.
     * Changes based on if system is charging or
     * calculating usage.
     *
     * - Returns: Remaining time text for menu bar
     */
    func getRemainingFormatted() -> String {
        if isCharging() || isFull() {
            return NSLocalizedString("Charging...", comment: "Indicating that battery is charging")
        } else if getRemainingTime() < 0 {
           return NSLocalizedString("Calculating...", comment: "Indicating battery usage calculation")
        } else {
            let time = getTimeInHoursAndMinutes();
            return String(time.hours) + ":" + String(time.minutes)
        }
    }
    
    /**
     * Get remaining time in hours and minutes to the hour
     *
     * - Returns: A tupel with remaining time
     *            in hours and minutes
     */
    func getTimeInHoursAndMinutes() -> (hours : String , minutes : String) {
        let hours = String(getRemainingTime() / 60)
        var minutes = String(getRemainingTime() % 60)
        
        if (getRemainingTime() % 60) < 10 {
            minutes = "0" + minutes
        }
        return (hours, minutes)
    }
    
    /**
     * Check if battery is charging
     *
     * - Returns: boolean
     */
    func isCharging() -> BooleanLiteralType {
        return (getPowerSourceInfo()[kIOPSIsChargingKey] as? BooleanLiteralType)!
    }
    
    /**
     * Check if battery is full nor not
     *
     * - Returns: boolean
     */
    func isFull() -> BooleanLiteralType {
        if (getPowerSourceInfo()[kIOPSIsChargedKey] as? BooleanLiteralType) != nil {
            return (getPowerSourceInfo()[kIOPSIsChargedKey] as? BooleanLiteralType)!
        } else {
            return false
        }
    }
    
}

//
//  AppDelegate.swift
//  ChargeMe
//
//  Created by Philipp Bolte on 23.06.18.
//  Copyright © 2018 Philipp Bolte. All rights reserved.
//

import Cocoa
import CoreFoundation
import IOKit.ps

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var charge: NSMenuItem!
    @IBOutlet weak var timeRemaining: NSMenuItem!
    @IBOutlet weak var batteryHealth: NSMenuItem!
    weak var timer: Timer?
    var lastNotificationAtPercentage = 0
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        timer!.invalidate()
        NSApplication.shared.terminate(self)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.menu = statusMenu
        
        let icon = NSImage(named: NSImage.Name(rawValue: "statusIcon"))
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        timer = Timer.scheduledTimer(
            timeInterval: 10.0,
            target: self,
            selector: #selector(startTimer(timer:)),
            userInfo: nil,
            repeats: true
        )
    }

    func applicationWillTerminate(_ aNotification: Notification) {}
    
    @objc func startTimer(timer: Timer) {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        
        for ps in sources {
            let info = IOPSGetPowerSourceDescription(snapshot, ps).takeUnretainedValue() as! [String: AnyObject]
            let isCharging = info[kIOPSIsChargingKey] as? BooleanLiteralType
            let capacity = info[kIOPSCurrentCapacityKey] as? Int
            let time = round(100 * (info[kIOPSTimeToEmptyKey] as? Double)!/60) / 100
            let health = info[kIOPSBatteryHealthKey] as? String
            
            charge.title = "Charge Level          \(capacity ?? 0)%"
            batteryHealth.title = "Health                     \(health ?? "unkown")"

            if isCharging! {
                timeRemaining.title = "Time Remaining     Charging..."
            } else if time < 0 {
                timeRemaining.title = "Time Remaining     Calculating..."
            } else {
                timeRemaining.title = "Time Remaining     \(time)h"
            }
            
            if capacity! < 5 {
                if lastNotificationAtPercentage != capacity && !isCharging! {
                    let notification:NSUserNotification = NSUserNotification()
                    notification.title = "ChargeMe"
                    notification.subtitle = "Your battery is running low!"
                    notification.informativeText = "Remaining: \(capacity ?? 0)%"
                    
                    notification.soundName = NSUserNotificationDefaultSoundName
                    
                    notification.deliveryDate = Date(timeIntervalSinceNow: 1)
                    let notificationcenter:NSUserNotificationCenter = NSUserNotificationCenter.default
                    notificationcenter.scheduleNotification(notification)
                    lastNotificationAtPercentage = capacity!
                }
            }
        }
    }
    
}

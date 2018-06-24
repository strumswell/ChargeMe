//
//  AppDelegate.swift
//  ChargeMe
//
//  Created by Philipp Bolte on 23.06.18.
//  Copyright © 2018 Philipp Bolte. All rights reserved.
//

import Cocoa
import CoreFoundation;
import IOKit.ps

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var charge: NSMenuItem!
    weak var timer: Timer?
    var lastNotificationAtPercentage = 0;
    
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
        charge.title = "Charge: loading..."
        
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
            let capacity = info[kIOPSCurrentCapacityKey] as? Int
            
            charge.title = "Charge: \(capacity ?? 0)%"
            
            if (capacity! < 5) {
                if (lastNotificationAtPercentage != capacity) {
                    let notification:NSUserNotification = NSUserNotification()
                    notification.title = "ChargeMe"
                    notification.subtitle = "Die Ladung ist im kritischen Bereich!"
                    notification.informativeText = "Restliche Ladung: \(capacity ?? 0)%"
                    
                    notification.soundName = NSUserNotificationDefaultSoundName
                    
                    notification.deliveryDate = Date(timeIntervalSinceNow: 1)
                    let notificationcenter:NSUserNotificationCenter = NSUserNotificationCenter.default
                    notificationcenter.scheduleNotification(notification)
                    lastNotificationAtPercentage = capacity!;
                }
            }
        }
    }
}


//
//  AppDelegate.swift
//  ChargeMe
//
//  Created by Philipp Bolte on 23.06.18.
//  Copyright © 2018 Philipp Bolte. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var charge: NSMenuItem!
    @IBOutlet weak var timeRemaining: NSMenuItem!
    @IBOutlet weak var batteryHealth: NSMenuItem!
    weak var timer: Timer?
    let battery = Battery()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var lastNotificationAtPercentage = 0
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        timer!.invalidate()
        NSApplication.shared.terminate(self)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
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
        charge.title = "\(NSLocalizedString("Charge Level", comment: ""))" + "\(battery.getBatteryLevel())%"
        batteryHealth.title = "\(NSLocalizedString("Health", comment: ""))" + "\(battery.getBatteryHealth())"
        timeRemaining.title = "\(NSLocalizedString("Time Remaining", comment: ""))" + "\(battery.getRemainingTimeText())"
        
        if battery.getBatteryLevel() < 5 {
            if lastNotificationAtPercentage != battery.getBatteryLevel() && !battery.isCharging() {
                sendNotification(title: "ChargeMe",
                                 subtitle: NSLocalizedString("Your battery is running low!", comment: "Information that battery is almost empty"),
                                 text: "\(NSLocalizedString("Remaining", comment: "Remaing battery charge"))" + "\(battery.getBatteryLevel())%")
                lastNotificationAtPercentage = battery.getBatteryLevel()
            }
        }
    }
    
    func sendNotification(title: String, subtitle: String, text: String) {
        let notification:NSUserNotification = NSUserNotification()
        let notificationcenter:NSUserNotificationCenter = NSUserNotificationCenter.default
        
        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = text
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.deliveryDate = Date(timeIntervalSinceNow: 1)
        notificationcenter.scheduleNotification(notification)
    }
    
}

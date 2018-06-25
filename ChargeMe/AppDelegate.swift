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
    let battery = BatteryAPI()
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
        charge.title = "Charge Level          \(battery.getBatteryLevel())%"
        batteryHealth.title = "Health                     \(battery.getBatteryHealth())"
        timeRemaining.title = "Time Remaining     \(battery.getRemainingTimeText())h"
        
        if battery.getBatteryLevel() < 5 {
            if lastNotificationAtPercentage != battery.getBatteryLevel() && !battery.isCharging() {
                let notification:NSUserNotification = NSUserNotification()
                let notificationcenter:NSUserNotificationCenter = NSUserNotificationCenter.default

                notification.title = "ChargeMe"
                notification.subtitle = "Your battery is running low!"
                notification.informativeText = "Remaining: \(battery.getBatteryLevel())%"
                notification.soundName = NSUserNotificationDefaultSoundName
                notification.deliveryDate = Date(timeIntervalSinceNow: 1)
                notificationcenter.scheduleNotification(notification)
                lastNotificationAtPercentage = battery.getBatteryLevel()
            }
        }
    }
    
}

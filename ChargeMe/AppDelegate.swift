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
        //Quit timer and application
        timer!.invalidate()
        NSApplication.shared.terminate(self)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //Prepare menu bar
        let icon = NSImage(named: NSImage.Name(rawValue: "statusIcon"))
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        //Start timer
        timer = Timer.scheduledTimer(
            timeInterval: 10.0,
            target: self,
            selector: #selector(startTimer(timer:)),
            userInfo: nil,
            repeats: true
        )
    }

    func applicationWillTerminate(_ aNotification: Notification) {}
    
    /**
     * Start timer that updates values in menu bar
     *
     * - Parameter timer: Timer object
     */
    @objc func startTimer(timer: Timer) {
        //Update information in menu bar
        charge.title = "\(NSLocalizedString("Charge Level", comment: ""))" + "\(battery.getBatteryLevel())%"
        batteryHealth.title = "\(NSLocalizedString("Health", comment: ""))" + "\(battery.getBatteryHealth())"
        timeRemaining.title = "\(NSLocalizedString("Time Remaining", comment: ""))" + "\(battery.getRemainingFormatted())"
        
        //Send notifcation under 5% every percent drop
        if battery.getBatteryLevel() < 5 {
            if lastNotificationAtPercentage != battery.getBatteryLevel() && !battery.isCharging() {
                sendNotification(title: "ChargeMe",
                                 subtitle: NSLocalizedString("Your battery is running low!", comment: "Information that battery is almost empty"),
                                 text: "\(NSLocalizedString("Remaining", comment: "Remaing battery charge"))" + "\(battery.getBatteryLevel())%")
                lastNotificationAtPercentage = battery.getBatteryLevel()
            }
        }
    }
    
    /**
     * Send a notification with title, subtitle and text
     *
     * - Parameter title: Title of notification
     * - Parameter subtitle: Subtitle of notification
     * - Parameter text: Actual text of notification
     */
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

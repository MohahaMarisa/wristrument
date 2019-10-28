//
//  ExtensionDelegate.swift
//  Wristrument WatchKit Extension
//
//  Created by Marisa Lu on 10/19/19.
//  Copyright © 2019 Marisa Lu. All rights reserved.
//

import WatchKit
import CoreMotion
import CoreHaptics

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    let motion = CMMotionManager();
    let deviceMotion = CMDeviceMotion();
    
    var ifMoved = false;
//    var timer: Timer? = nil;
    
    func startAccelerometers() {
        print("started Accelerometeres!")
        // Make sure the accelerometer hardware is available.
        if self.motion.isAccelerometerAvailable {
            print("cuz they available")
            self.motion.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
            self.motion.startAccelerometerUpdates()
            // Configure a timer to fetch the data.
            let timer = Timer(fire: Date(), interval: (1.0/60.0),
                  repeats: true, block: { (timer) in
                    
                    let obj = WKInterfaceDevice.current()
                    
                    if let data = self.motion.accelerometerData{
                        let x = data.acceleration.x
                        let y = data.acceleration.y
                        let z = data.acceleration.z

                        // Use the accelerometer data in your app.
                        if(abs(x) + abs(y) + abs(z) > 2){
                            print("hm: \(x),\(y),\(z)");
                            self.ifMoved = true;
                        }else if self.ifMoved{
                            obj.play(WKHapticType.start);
                            self.ifMoved = false;
                            print("WWWWOOOWW");
                        }
                    }
            })

            // Add the timer to the current run loop.
            RunLoop.current.add(timer, forMode: .default)
        }else{
            print("but they not available")
        }
    }

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        print("application finished launching")
        startAccelerometers()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        startAccelerometers()
        print("active AGAIN")
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        print("resign")
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}

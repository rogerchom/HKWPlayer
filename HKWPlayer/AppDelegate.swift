//
//  AppDelegate.swift
//  TestFC
//
//  Created by Seonman Kim on 12/12/14.
//  Copyright (c) 2014 Seonman Kim. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

var g_timeElapsed = 0
let kAppGroupName = "group.com.logicaldimension.HKWPlayer"
var g_wormhole = MMWormhole(applicationGroupIdentifier: kAppGroupName, optionalDirectory: "wormhole")
var g_playInitiatedByWatch = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, HKWDeviceEventHandlerDelegate, HKWPlayerEventHandlerDelegate {

    var sleepPreventer : MMPDeepSleepPreventer!

    var window: UIWindow?
    
    var deviceList: NSMutableArray!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let defaults = NSUserDefaults(suiteName: kAppGroupName)
        defaults!.setObject("I am iPhone", forKey: "test")
        defaults?.synchronize()
        
        // prevent from turning into background
        sleepPreventer = MMPDeepSleepPreventer()
        sleepPreventer.startPreventSleep()

        return true
    }
    

    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        
        if !HKWControlHandler.sharedInstance().isInitialized() {
            HKWDeviceEventHandlerSingleton.sharedInstance().delegate = self
            HKWPlayerEventHandlerSingleton.sharedInstance().delegate = self
            
            // firecaset has not been started vbefore. Start now
            println("initializing HKWirelessControl... ")
            if HKWControlHandler.sharedInstance().initializeHKWirelessController(g_licenseKey) != 0 {
                println("initializeHKWirelessControl failed : invalid license key")
                return
            }
            
            sleep(1)
            saveDeviceList()
            
            if g_playList.count == 0 {
                loadPlaylistItems()
            }
        }

        
        var eventCreated = false
        if let persistentID = userInfo?["playItem"] as? String {
            println("playItem: persistentID: \(persistentID)")
            
            // query the media library
            let query = MPMediaQuery.songsQuery()
            
            let predicate = MPMediaPropertyPredicate(value: persistentID,
                forProperty: MPMediaItemPropertyPersistentID)
            query.addFilterPredicate(predicate)
            let item = query.items.first as? MPMediaItem
            
            let assetUrl = item!.assetURL
            let item_title = item!.title
            let item_duration = item!.playbackDuration
            
            HKWControlHandler.sharedInstance().stop()
            
            println("URLString: \(assetUrl.absoluteString)")
            
            if HKWControlHandler.sharedInstance().playCAF(assetUrl, songName: item_title, resumeFlag: false) {
                println("playing")
                g_playInitiatedByWatch = true
            } else {
                println("error in playing")
            }
            
            // find the selectedIndex
            for (index, item) in enumerate(g_playList) {
                if item.item_persistentID == persistentID {
                    g_selectedIndex = index
                }
            }
            
            eventCreated = true
            reply(["playItem": NSNumber(bool: eventCreated)])

        } else if let persistentID = userInfo?["resumeItem"] as? String {
            println("resumeItem: persistentID: \(persistentID)")
            
            // query the media library
            let query = MPMediaQuery.songsQuery()
            
            let predicate = MPMediaPropertyPredicate(value: persistentID,
                forProperty: MPMediaItemPropertyPersistentID)
            query.addFilterPredicate(predicate)
            let item = query.items.first as? MPMediaItem
            
            let assetUrl = item!.assetURL
            let item_title = item!.title
            let item_duration = item!.playbackDuration
            
            HKWControlHandler.sharedInstance().stop()
            
            println("URLString: \(assetUrl.absoluteString)")
            if HKWControlHandler.sharedInstance().playCAF(assetUrl, songName: item_title, resumeFlag: true) {
                println("playing")
                g_playInitiatedByWatch = true

            } else {
                println("error in playing")
            }
            
            eventCreated = true
            reply(["resumeItem": NSNumber(bool: eventCreated)])
            
        }  else if let persistentID = userInfo?["pauseItem"] as? String {
            println("pauseItem: persistentID: \(persistentID)")

            HKWControlHandler.sharedInstance().stop()
            eventCreated = true
            reply(["pauseItem": NSNumber(bool: eventCreated)])
            
        } else if let value = userInfo?["setVolume"] as? NSNumber {
            println("setVolume: value: \(value)")

            var volume = value.floatValue
            HKWControlHandler.sharedInstance().setVolume(Int(volume))
            eventCreated = true
            reply(["setVolume": NSNumber(bool: eventCreated)])

            
        } else if let str = userInfo?["setVolumeDevice"] as? String {
            println("setVolumeDevice: str: \(str)")
            var valueArray = str.componentsSeparatedByString(":")
            var deviceId: CLongLong = CLongLong(valueArray[0].toInt()!)
            var volume = valueArray[1].toInt()!
            
            HKWControlHandler.sharedInstance().setVolumeDevice(deviceId, volume: volume)
            eventCreated = true
            reply(["setVolumeDevice": NSNumber(bool: eventCreated)])
            
        } else if let value = userInfo?["getVolume"] as? NSNumber {
            println("getVolume: value: \(value)")

            var volume = value.floatValue
            var newVolume = HKWControlHandler.sharedInstance().getVolume()
            eventCreated = true
            reply(["getVolume": NSNumber(integer: newVolume)])
            
        } else if let str = userInfo?["setActive"] as? String {
            println("setActive: str: \(str)")
            
            var valueArray = str.componentsSeparatedByString(":")
            var deviceId: CLongLong = CLongLong(valueArray[0].toInt()!)
            let isActive = valueArray[1] == "true" ? true : false
            println("isActive: \(isActive)")
            
            if isActive {
                HKWControlHandler.sharedInstance().addDeviceToSession(deviceId)
            } else {
                HKWControlHandler.sharedInstance().removeDeviceFromSession(deviceId)

            }
            eventCreated = true
            reply(["setActive": NSNumber(bool: eventCreated)])
            
        } else if let value = userInfo?["getElapsedTime"] as? NSNumber {
            println("getElapsedTime: return value: \(g_timeElapsed)")
            
            reply(["getElapsedTime": NSNumber(integer: g_timeElapsed)])
            
        } else if let value = userInfo?["getSpeakerCount"] as? NSNumber {
            println("getSpeakerCount: value: \(value)")

            var deviceCount = HKWControlHandler.sharedInstance().getDeviceCount()
            println("getSpeakerCount: return \(deviceCount)")

            reply(["getSpeakerCount": NSNumber(integer: deviceCount)])
            
        } else if let value = userInfo?["getCurrentItem"] as? NSString {
            println("received getCurrentItem")
            var curItem = ""
            if g_selectedIndex >= 0 {
                curItem = g_playList[g_selectedIndex].item_persistentID
            } else {
                curItem = "N/A"
            }
            
            println("return : \(curItem)")
            reply(["getCurrentItem": curItem])
            
        }  else if let value = userInfo?["getIsPlaying"] as? NSString {
            println("received getCurrentTitle")

            println("return : \(HKWControlHandler.sharedInstance().isPlaying())")

            reply(["getIsPlaying": NSNumber(bool: HKWControlHandler.sharedInstance().isPlaying())])
        }

        
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        println("willResignActive")

    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        println("didEnterBackground")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        println("didBecomeActive")

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.savoritelist.Savorite" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("HKWPlayer", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("HKWPlayer.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }


    func saveDeviceList() {

        
        var deviceCount = HKWControlHandler.sharedInstance().getDeviceCount()
        
        self.deviceList = NSMutableArray()
        
        for var i = 0; i < deviceCount; i++  {
            var deviceInfo = HKWControlHandler.sharedInstance().getDeviceInfoByIndex(i)
            var data = "\(deviceInfo.deviceName):\(deviceInfo.groupName):\(deviceInfo.modelName):\(deviceInfo.active):\(deviceInfo.volume):\(deviceInfo.deviceId)"
            self.deviceList.addObject(data)
        }
        g_wormhole.passMessageObject(["speakerList": self.deviceList], identifier: "speakerList")
    }
    
    
    func hkwDeviceStateUpdated(deviceId: Int64, withReason reason: Int) {
        println("appDelegate - hkwDeviceStateUpdated")
        saveDeviceList()
    }
    
    func hkwErrorOccurred(errorCode: Int, withErrorMessage errorMesg: String!) {
        saveDeviceList()
    }
    
    func hkwPlaybackTimeChanged(timeElapsed: Int) {
        g_timeElapsed = timeElapsed
        g_wormhole.passMessageObject(["timeElapsed": timeElapsed], identifier: "playbackTimer")
    }
    
    func hkwPlaybackStateChanged(playState: Int) {
        println("+++++++++++++++++++ PlaybackStateChanged: \(playState)")
        
    }
    
    func hkwPlayEnded() {
        // notify Watch of PlayEnded and also the new item to play
        // (-1) means there is no indication about the next song.
        println("hkwPlayEnded() in AppDelegate")
        g_wormhole.passMessageObject(["playEndedByPhone": (-1)], identifier: "playbackEvent")
    }
    
}


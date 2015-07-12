//
//  StreamingActivity.swift
//  HKPage
//
//  Created by Seonman Kim on 3/18/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

class StreamingActivityView: UIView {
    let kWidth = 4
    let kPadding = 2
    let kBarCount = 3
//    let kAppBakgroundColor = RGB(72, 72, 72)
//    let kAppBakgroundColor = UIColor(red: 72.0/255.0, green: 72.0/255.0, blue: 72.0/255.0, alpha: 1.0)
    
    var timer : NSTimer!
    var barArray: [UIImageView] = []
    var barColor: UIColor!
    
    func initColor(red: CGFloat, green: CGFloat, blue: CGFloat) {
        
        hidden = true
        barColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        var tempBarArray = [UIImageView]()
        
        for var i = 0; i < kBarCount; i++ {
            var bar = UIImageView(frame: CGRectMake(CGFloat(Float(i * (kWidth + kPadding))), 0.0, CGFloat(Float(kWidth)), 1.0))
            bar.image = imageWithColor(barColor)

            self.addSubview(bar)
            tempBarArray.append(bar)
        }
        
        barArray = [UIImageView](tempBarArray)
        
        var transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2 * 2))
        self.transform = transform
    }
    
//    convenience init() {
//        self.init(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0)
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initColor(100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0)

    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initColor(100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0)
    }

    func startAnimation() {
        println("startAnimation")
        self.hidden = false
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(0.15, target: self, selector: Selector("ticker"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    
    func pauseAnimation() {
        timer.invalidate()
        timer = nil
        
    }
    
    func stopAnimation() {
        println("stopAnimation")

        self.hidden = true
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    func ticker() {
        UIView.animateWithDuration(0.15, animations: {
            for bar in self.barArray {
                var rect = bar.frame
                rect.size.height = CGFloat(arc4random()) % (self.bounds.size.height) + 1.0
                bar.frame = rect
            }
        })
    }
    
    func imageWithColor(color: UIColor) -> UIImage {
        return imageWithColor(color, size:CGSizeMake(1, 1))
    }
    
    func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        
        var rect: CGRect = CGRectMake(0.0, 0.0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        var context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        var theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return theImage;
    }
}

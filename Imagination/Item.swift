//
//  Item.swift
//  Imagination
//
//  Created by Star on 16/1/2.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit

class Item: NSObject {
    static let coolColor = UIColor.orangeColor()
    static let justOkColor = UIColor.init(red: 4.0/255.0, green: 119.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    static let whyColor = UIColor.redColor()
    static let defaultColor = UIColor.init(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1)
    private let moodColor = [UIColor.darkGrayColor(),Item.coolColor,Item.justOkColor,Item.whyColor]
    private let moodStrings = ["NA","Cool","Just OK","Confused"]
    var mood:Int//心情
    
    var content:String//内容
    var color:UIColor
    var moodString:String
    var place:(name:String,latitude:Double,longtitude:Double)
    
    init(contentString:String) {
        
        let array = contentString.componentsSeparatedByString("-")
        if array.count >= 2 {
            self.content = array[0]
            self.mood = Int(array[1])!
            if array.count >= 3{
                let string = array[2]
                let sb = string.componentsSeparatedByString(",")
                self.place = (sb[0] ,Double(sb[1])!,Double(sb[2])!)
            }else{
                self.place = ("",0,0)
            }
        } else {
            self.content = contentString
            self.mood = 0
            self.place = ("",0,0)
        }
        self.color = self.moodColor[self.mood]
        self.moodString = self.moodStrings[self.mood]
        super.init()
    }
    
    static func ItemString(content:String,mood:Int) ->String {
        return content + "-" + "\(mood)"
    }
    
    class func ItemString(content:String,mood:Int,GPSName:String,latitude:Double,longtitude:Double) ->String {
        return content + "-" + "\(mood)" + "-" + "\(GPSName),\(latitude),\(longtitude)"
    }
}

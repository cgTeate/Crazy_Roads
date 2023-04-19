//
//  Utils.swift
//  Crazy_Roads iOS
//
//  Created by Calvin Grant Teater on 4/18/23.
//

import Foundation
import SceneKit

//helper functions to calculate radians values for the angles, so we don't have to calculate it manually
let degreesPerRadians = Float(Double.pi/180)
let radiansPerDegrees = Float(180/Double.pi)

func toRadians(angle: Float) -> Float {
    return angle * degreesPerRadians
}

func toRadians(angle: CGFloat) -> CGFloat {
    return angle * CGFloat(degreesPerRadians)
}

//bool function to decide whether we use a grass or road lane
func randomBool(odds: Int) -> Bool {
    let random = arc4random_uniform(UInt32(odds))
    if random < 1 {
        return true
    } else {
        return false
    }
}

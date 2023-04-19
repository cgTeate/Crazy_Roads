//
//  Utils.swift
//  Crazy_Roads iOS
//
//  Created by Calvin Grant Teater on 4/18/23.
//

import Foundation
import SceneKit

struct Models {
    
    private static let treeScene = SCNScene(named: "Art.scnassets/Tree.scn")!
    static let tree = treeScene.rootNode.childNode(withName: "tree", recursively: true)!
    
    private static let hedgeScene = SCNScene(named: "Art.scnassets/Hedge.scn")!
    static let hedge = hedgeScene.rootNode.childNode(withName: "hedge", recursively: true)!
    
    private static let carScene = SCNScene(named: "Art.scnassets/PurpleCar.scn")!
    static let car = carScene.rootNode.childNode(withName: "car", recursively: true)!
    
    private static let blueTruckScene = SCNScene(named: "Art.scnassets/BlueTruck.scn")!
    static let blueTruck = blueTruckScene.rootNode.childNode(withName: "truck", recursively: true)!
    
    private static let firetruckScene = SCNScene(named: "Art.scnassets/Firetruck.scn")!
    static let firetruck = firetruckScene.rootNode.childNode(withName: "truck", recursively: true)!
}

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

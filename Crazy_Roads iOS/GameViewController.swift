//
//  GameViewController.swift
//  Crazy_Roads iOS
//
//  Created by Calvin Grant Teater on 4/18/23.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    //global variables
    var scene: SCNScene!
    var sceneView: SCNView!
    
    var cameraNode = SCNNode()
    var mapNode = SCNNode() //contains all of the lanes as children, so we group them together
    var lanes = [LaneNode]() //contains all of the lane nodes as you move through the game
    var laneCount = 0 //used to position lanes correctly, each lane should be placed after the preceding lane
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupFloor()
        setupCamera()
    }
    
    //initializes both scene and sceneView properties
    func setupScene() {
        sceneView = (view as! SCNView)
        scene = SCNScene()
        
        sceneView.scene = scene
        
        scene.rootNode.addChildNode(mapNode)
        
        for _ in 0..<20 {
            let type = randomBool(odds: 3) ? LaneType.grass : LaneType.road
            let lane = LaneNode(type: type, width: 21)
            lane.position = SCNVector3(x: 0, y: 0, z: 5 - Float(laneCount))
            laneCount += 1
            lanes.append(lane)
            mapNode.addChildNode(lane)
            
        }
    }
    
    //Create floor to use it as a plane, so we can position all of our elements on
    func setupFloor() {
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIImage(named: "Art.scnassets/darkgrass.png")
        floor.firstMaterial?.diffuse.wrapS = .repeat
        floor.firstMaterial?.diffuse.wrapT = .repeat
        floor.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(12.5, 12.5, 12.5)
        floor.reflectivity = 0.01
        
        let floorNode = SCNNode(geometry: floor)
        scene.rootNode.addChildNode(floorNode)
    }
    
    //creates camera to look down at the grass floor
    func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 0)
        cameraNode.eulerAngles = SCNVector3(x: -toRadians(angle: 60), y: toRadians(angle: 20), z: 0)
        scene.rootNode.addChildNode(cameraNode)
    }
}

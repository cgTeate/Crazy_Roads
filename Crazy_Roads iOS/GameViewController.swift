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
    var lightNode = SCNNode() //parent node that contains all of the lights
    var playerNode = SCNNode()
    var mapNode = SCNNode() //contains all of the lanes as children, so we group them together
    var lanes = [LaneNode]() //contains all of the lane nodes as you move through the game
    var laneCount = 0 //used to position lanes correctly, each lane should be placed after the preceding lane
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupPlayer()
        setupFloor()
        setupCamera()
        setupLight()
        setUpGestures()
        setupActions()
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
    
    func setupPlayer() {
        guard let playerScene = SCNScene(named: "Art.scnassets/Chicken.scn") else {
            return
        }
        if let player = playerScene.rootNode.childNode(withName: "player", recursively: true) {
            playerNode = player
            playerNode.position = SCNVector3(x: 0, y: 0.3, z: 0)
            scene.rootNode.addChildNode(playerNode)
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
    
    //creates two light nodes
        //one ambient light for evenly distributed light throughout scene
        //one directional light which will allow to cast shadows and emphasize three dimensional elements
    func setupLight() {
        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        
        let directionalNode = SCNNode()
        directionalNode.light = SCNLight()
        directionalNode.light?.type = .directional
        directionalNode.light?.castsShadow = true
        directionalNode.light?.shadowColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        directionalNode.position = SCNVector3(x: -5, y: 5, z: 0)
        directionalNode.eulerAngles = SCNVector3(x: 0, y: -toRadians(angle: 90), z: -toRadians(angle: 45))
        
        lightNode.addChildNode(ambientNode)
        lightNode.addChildNode(directionalNode)
        lightNode.position = cameraNode.position
        scene.rootNode.addChildNode(lightNode)
    }
    
    func setUpGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUp.direction = .up
        sceneView.addGestureRecognizer(swipeUp)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right
        sceneView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeft.direction = .left
        sceneView.addGestureRecognizer(swipeLeft)
    }
    
    func setupActions() {
        
    }
    
    
}

extension GameViewController {
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        
    }
        
}

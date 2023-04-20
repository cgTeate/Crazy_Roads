//
//  GameViewController.swift
//  Crazy_Roads iOS
//
//  Created by Calvin Grant Teater on 4/18/23.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

enum GameState {
    case menu, playing, gameOver
}

class GameViewController: UIViewController {
    
    //global variables
    var scene: SCNScene!
    var sceneView: SCNView!
    var gameHUD: GameHUD!
    var gameState = GameState.menu
    var score = 0
    
    var cameraNode = SCNNode()
    var lightNode = SCNNode() //parent node that contains all of the lights
    var playerNode = SCNNode()
    var collisionNode = CollisionNode()
    var mapNode = SCNNode() //contains all of the lanes as children, so we group them together
    var lanes = [LaneNode]() //contains all of the lane nodes as you move through the game
    var laneCount = 0 //used to position lanes correctly, each lane should be placed after the preceding lane
    
    var jumpForwardAction: SCNAction?
    var jumpRightAction: SCNAction?
    var jumpLeftAction: SCNAction?
    var driveRightAction: SCNAction?
    var driveLeftAction: SCNAction?
    var dieAction: SCNAction?

    var frontBlocked = false //bool values used to determine if a certain direction is currently blocked
    var rightBlocked = false
    var leftBlocked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildGame()
    }
    
    //override touches began to react to touches on the screen
    //If gamestate is on menu, then the gestures will be setup
    //prevents us from swiping in the menu and breaking the game
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .menu:
            setupGestures()
            gameHUD = GameHUD(with: sceneView.bounds.size, menu: false)
            sceneView.overlaySKScene = gameHUD
            sceneView.overlaySKScene?.isUserInteractionEnabled = false
            gameState = .playing
        default:
            break
        }
    }
    
    //resets the game to original state
    func resetGame() {
        scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        scene = nil
        gameState = .menu
        score = 0
        laneCount = 0
        lanes = [LaneNode]()
        buildGame()
    }
    
    func buildGame() {
        setupScene()
        setupPlayer()
        setupCollisioNode()
        setupFloor()
        setupCamera()
        setupLight()
        setupActions()
        setupTraffic()
    }
    
    //initializes both scene and sceneView properties
    func setupScene() {
        sceneView = (view as! SCNView)
        sceneView.delegate = self
        
        scene = SCNScene()
        scene.physicsWorld.contactDelegate = self //makes sure physical contacts in our scene get handled in physics delegate method down in the extension
        //prevents reloading the scene, which causes errors
        sceneView.present(scene, with: .fade(withDuration: 0.5), incomingPointOfView: nil, completionHandler: nil)
        
        //initializes menu Heads Up Display when app loads, runs in the main Thread to avoid crashes
        DispatchQueue.main.async {
            self.gameHUD = GameHUD(with: self.sceneView.bounds.size, menu: true)
            self.sceneView.overlaySKScene = self.gameHUD
            self.sceneView.overlaySKScene?.isUserInteractionEnabled = false
        }
        
        scene.rootNode.addChildNode(mapNode)
        
        //spawns grasss lanes first then road lanes so the player does not start on a road
        for _ in 0..<10 {
            createNewLane(initial: true)
        }
        for _ in 0..<10 {
            createNewLane(initial: false)
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
    
    //sets up the collision nodes around the player
    func setupCollisioNode() {
        collisionNode = CollisionNode()
        collisionNode.position = playerNode.position
        scene.rootNode.addChildNode(collisionNode)
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
    
    func setupGestures() {
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
    
    //sets up the action movement
    func setupActions() {
        let moveUpAction = SCNAction.moveBy(x: 0, y: 1.0, z: 0, duration: 0.1)
        let moveDownAction = SCNAction.moveBy(x: 0, y: -1.0, z: 0, duration: 0.1)
        moveUpAction.timingMode = .easeOut
        moveDownAction.timingMode = .easeIn
        let jumpAction = SCNAction.sequence([moveUpAction,moveDownAction])
        
        let moveForwardAction = SCNAction.moveBy(x: 0, y: 0, z: -1.0, duration: 0.2)
        let moveRightAction = SCNAction.moveBy(x: 1.0, y: 0, z: 0, duration: 0.2)
        let moveLeftAction = SCNAction.moveBy(x: -1.0, y: 0, z: 0, duration: 0.2)
        
        let turnForwardAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 180), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnRightAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 90), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnLeftAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: -90), z: 0, duration: 0.2, usesShortestUnitArc: true)
        
        jumpForwardAction = SCNAction.group([turnForwardAction, jumpAction, moveForwardAction])
        jumpRightAction = SCNAction.group([turnRightAction, jumpAction, moveRightAction])
        jumpLeftAction = SCNAction.group([turnLeftAction, jumpAction, moveLeftAction])
        
        driveRightAction = SCNAction.repeatForever(SCNAction.moveBy(x: 2.0, y: 0, z: 0, duration: 1.0))
        driveLeftAction = SCNAction.repeatForever(SCNAction.moveBy(x: -2.0, y: 0, z: 0, duration: 1.0))
        
        dieAction = SCNAction.moveBy(x: 0, y: 5, z: 0, duration: 1.0)
        
    }
    
    //initially sets up driving animations for the lanes
    func setupTraffic() {
        for lane in lanes {
            if let trafficNode = lane.trafficNode {
                addActions(for: trafficNode)
            }
        }
    }
    
    func jumpForward() {
        if let action = jumpForwardAction {
            addLanes()
            playerNode.runAction(action, completionHandler: {
                self.checkBlocks()
                self.score += 1
                self.gameHUD.pointsLabel?.text = "\(self.score)"
            })
        }
    }
    
    //updates camera position and light nodes according to player position
    func updatePositions() {
        collisionNode.position = playerNode.position
        
        //offsets the camera to the right and back of the player model
        let diffX = (playerNode.position.x + 1 - cameraNode.position.x)
        let diffZ = (playerNode.position.z + 2 - cameraNode.position.z)
        cameraNode.position.x += diffX
        cameraNode.position.z += diffZ
        
        lightNode.position = cameraNode.position
    }
    
    //updates traffic to reposition at the beginning of the lane when traffic gets to the end of the lane
    func updateTraffic() {
        for lane in lanes {
            guard let trafficNode = lane.trafficNode else {
                continue
            }
            for vehicle in trafficNode.childNodes {
                if vehicle.position.x > 10 {
                    vehicle.position.x = -10
                } else if vehicle.position.x < -10 {
                    vehicle.position.x = 10
                }
            }
        }
    }
    
    //adds more lanes as the player moves forward
    func addLanes() {
        for _ in 0...1 {
            createNewLane(initial: false)
        }
        removeUnusedLanes()
    }
    
    //removes lanes behind the player to handle memory overload
    //similar to removing elements from the beginning of an ArrayList in Java
    func removeUnusedLanes() {
        //loop through each child in the mapNode
        //check if passed node is not visible inside the view of another node (camera) and is behind the camera
        for child in mapNode.childNodes {
            if !sceneView.isNode(child, insideFrustumOf: cameraNode) && child.worldPosition.z > playerNode.worldPosition.z {
                child.removeFromParentNode()
                lanes.removeFirst()
                print("Removed unused lane")
            }
        }
    }
    
    //spawns new lanes
    func createNewLane(initial: Bool) {
        let type = randomBool(odds: 3) || initial ? LaneType.grass : LaneType.road
        let lane = LaneNode(type: type, width: 21)
        lane.position = SCNVector3(x: 0, y: 0, z: 5 - Float(laneCount))
        laneCount += 1
        lanes.append(lane)
        mapNode.addChildNode(lane)
        
        //only gives us a value for road lanes that have valid traffic
        //If lane is a road, then call addActions method to add driving animations for the vehicles
        if let trafficNode = lane.trafficNode {
            addActions(for: trafficNode)
        }
    }
    
    
    func addActions(for trafficNode: TrafficNode) {
        guard let driveAction = trafficNode.directionRight ? driveRightAction : driveLeftAction else {
            return
        }
        driveAction.speed = 1/CGFloat(trafficNode.type + 1) + 0.5
        for vehicle in trafficNode.childNodes {
            vehicle.removeAllActions() //removes any existing actions before adding new actions to scene
            vehicle.runAction(driveAction)
        }
    }
    
    //removes all gesture recognizers, runs die movement, and resets the game
    func gameOver() {
        DispatchQueue.main.async {
            if let gestureRecognizers = self.sceneView.gestureRecognizers {
                for recognizer in gestureRecognizers {
                    self.sceneView.removeGestureRecognizer(recognizer)
                }
            }
        }
        gameState = .gameOver
        if let action = dieAction {
            playerNode.runAction(action, completionHandler: {
                self.resetGame()
            })
        }
    }
    
}

//SCNSceneRendererDelegate handles updates to the game
extension GameViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        updatePositions()
        updateTraffic()
    }
    
}

//SCNPhysicsContactDelegate used to check for contacts in the game
extension GameViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard let categoryA = contact.nodeA.physicsBody?.categoryBitMask, let categoryB = contact.nodeB.physicsBody?.categoryBitMask else {
            return
        }
        
        let mask = categoryA | categoryB
        
        switch mask {
        case PhysicsCategory.chicken | PhysicsCategory.vehicle:
            gameOver()
        case PhysicsCategory.vegetation | PhysicsCategory.collisionTestFront:
            frontBlocked = true
        case PhysicsCategory.vegetation | PhysicsCategory.collisionTestRight:
            rightBlocked = true
        case PhysicsCategory.vegetation | PhysicsCategory.collisionTestLeft:
            leftBlocked = true
        default:
            break
        }
    }
    
}

//handleSwipe is similar to MouseHandler in Java Swing, handles the actions/events/animations
extension GameViewController {
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.up:
            if !frontBlocked {
                jumpForward()
            }
        case UISwipeGestureRecognizer.Direction.right:
            if playerNode.position.x < 10 && !rightBlocked {
                if let action = jumpRightAction {
                    playerNode.runAction(action, completionHandler: {
                        self.checkBlocks()
                    })
                }
            }
        case UISwipeGestureRecognizer.Direction.left:
            if playerNode.position.x > -10 && !leftBlocked {
                if let action = jumpLeftAction {
                    playerNode.runAction(action, completionHandler: {
                        self.checkBlocks()
                    })
                }
            }
        default:
            break
        }
    }
    
    //checks if the blocked directions are able to be unblocked
    func checkBlocks() {
        if scene.physicsWorld.contactTest(with: collisionNode.front.physicsBody!, options: nil).isEmpty {
            frontBlocked = false
        }
        if scene.physicsWorld.contactTest(with: collisionNode.right.physicsBody!, options: nil).isEmpty {
            rightBlocked = false
        }
        if scene.physicsWorld.contactTest(with: collisionNode.left.physicsBody!, options: nil).isEmpty {
            leftBlocked = false
        }
    }
        
}

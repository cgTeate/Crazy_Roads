//
//  CollisionNode.swift
//  Crazy_Roads iOS
//
//  Created by Calvin Grant Teater on 4/19/23.
//

import SceneKit

class CollisionNode: SCNNode {
    
    let front: SCNNode
    let right: SCNNode
    let left: SCNNode
    
    //purpose to have global variables to instantly create physicsbodies when we initialize a collisionNode instance
    override init() {
        front = SCNNode()
        right = SCNNode()
        left = SCNNode()
        
        super.init()
        createPhysicsBodies()
    }
    
    //places collision nodes around the player
    func createPhysicsBodies() {
        let boxGeometry = SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0)
        boxGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        
        let shape = SCNPhysicsShape(geometry: boxGeometry, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        
        front.geometry = boxGeometry //renders the nodes as three little cubes when added to scene
        right.geometry = boxGeometry
        left.geometry = boxGeometry
        
        front.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        front.physicsBody?.categoryBitMask = PhysicsCategory.collisionTestFront
        front.physicsBody?.contactTestBitMask = PhysicsCategory.vegetation
        
        right.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        right.physicsBody?.categoryBitMask = PhysicsCategory.collisionTestRight
        right.physicsBody?.contactTestBitMask = PhysicsCategory.vegetation
        
        left.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        left.physicsBody?.categoryBitMask = PhysicsCategory.collisionTestLeft
        left.physicsBody?.contactTestBitMask = PhysicsCategory.vegetation
        
        front.position = SCNVector3(x: 0, y: 0.5, z: -1)
        right.position = SCNVector3(x: 1, y: 0.5, z: 0)
        left.position = SCNVector3(x: -1, y: 0.5, z: 0)
        
        addChildNode(front)
        addChildNode(right)
        addChildNode(left)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  LaneNode.swift
//  Crazy_Roads iOS
//
//  Created by Calvin Grant Teater on 4/18/23.
//

import SceneKit

enum LaneType {
    case grass, road
}

class LaneNode: SCNNode {
    
    let type: LaneType
    
    init(type: LaneType, width: CGFloat) {
        self.type = type
        super.init()
        
        switch type {
        case .grass:
            guard let grassTexture = UIImage(named: "Art.scnassets/grass.png") else {
                break
            }
            createLane(width: width, height: 0.4, image: grassTexture)
        case .road:
            guard let roadTexture = UIImage(named: "Art.scnassets/asphalt.png") else {
                break
            }
            createLane(width: width, height: 0.05, image: roadTexture)
        }
    }
    
    func createLane(width: CGFloat, height: CGFloat, image: UIImage) {
        let laneGeometry = SCNBox(width: width, height: height, length: 1, chamferRadius: 0)
        laneGeometry.firstMaterial?.diffuse.contents = image
        laneGeometry.firstMaterial?.diffuse.wrapT = .repeat
        laneGeometry.firstMaterial?.diffuse.wrapS = .repeat
        laneGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), 1, 1)
        let laneNode = SCNNode(geometry: laneGeometry)
        
        addChildNode(laneNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

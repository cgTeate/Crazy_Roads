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

//new class with properties for determining the type of vehicle driving on the road and the its direction
class TrafficNode: SCNNode {
    
    let type: Int
    let directionRight: Bool
    
    init(type: Int, directionRight: Bool) {
        self.type = type
        self.directionRight = directionRight
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class LaneNode: SCNNode {
    
    let type: LaneType
    var trafficNode: TrafficNode? //optional because it will only be set if type of lane is road
    
    //initializes lane depending on the type (grass or road)
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
            trafficNode = TrafficNode(type: Int(arc4random_uniform(UInt32(3))), directionRight: randomBool(odds: 2))
            addChildNode(trafficNode!)
            createLane(width: width, height: 0.05, image: roadTexture)
        }
    }
    
    //creates a visual node from the type
    func createLane(width: CGFloat, height: CGFloat, image: UIImage) {
        let laneGeometry = SCNBox(width: width, height: height, length: 1, chamferRadius: 0)
        laneGeometry.firstMaterial?.diffuse.contents = image
        laneGeometry.firstMaterial?.diffuse.wrapT = .repeat
        laneGeometry.firstMaterial?.diffuse.wrapS = .repeat
        laneGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), 1, 1)
        let laneNode = SCNNode(geometry: laneGeometry)
        
        addChildNode(laneNode)
        addElements(width, laneNode)
    }
    
    //used to add appropriate models for the each lane
    func addElements(_ width: CGFloat, _ laneNode: SCNNode) {
        var carGap = 0
        
        for index in 0..<Int(width) {
            if type == .grass {
                if randomBool(odds: 7) {
                    let vegetation = getVegetation()
                    vegetation.position = SCNVector3(x: 10 - Float(index), y: 0, z: 0)
                    laneNode.addChildNode(vegetation)
                }
            } else if type == .road {
                //spawns cars depending on the gap between them so none overlap
                carGap += 1
                if carGap > 3 {
                    guard let trafficNode = trafficNode else {
                        continue
                    }
                    if randomBool(odds: 4) {
                        carGap = 0
                        let vehicle = getVehicle(for: trafficNode.type)
                        vehicle.position = SCNVector3(x: 10 - Float(index), y: 0, z: 0)
                        vehicle.eulerAngles = trafficNode.directionRight ? SCNVector3Zero : SCNVector3(x: 0, y: toRadians(angle: 180), z: 0)
                        trafficNode.addChildNode(vehicle)
                    }
                }
            }
        }
    }
    
    //creates a copy node of the preset model defined in Utils (treeScene, hedgeScene)
    //reduces memory usage
    func getVegetation() -> SCNNode {
        let vegetation = randomBool(odds: 2) ? Models.tree.clone() : Models.hedge.clone()
        return vegetation
    }
    
    //creates a copy node of the vehicle type, only allows 1 vehicle type per lane
    func getVehicle(for type: Int) -> SCNNode {
        switch type {
        case 0:
            return Models.car.clone()
        case 1:
            return Models.blueTruck.clone()
        case 2:
            return Models.firetruck.clone()
        default:
            return Models.car.clone()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

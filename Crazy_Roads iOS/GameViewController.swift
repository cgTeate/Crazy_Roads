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

    var scene: SCNScene!
    var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    //initializes both scene and sceneView properties
    func setupScene() {
        sceneView = (view as! SCNView)
        scene = SCNScene()
        
        sceneView.scene = scene
    }
    
}

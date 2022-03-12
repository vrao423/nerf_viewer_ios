//
//  ViewController.swift
//  BrightnessShader
//
//  Created by Venkat Rao on 3/8/22.
//

import UIKit
import MetalKit
import SceneKit

class ViewController: UIViewController {

//  var metalView: MTKView {
//    return view as! MTKView
//  }

  var device: MTLDevice!

  var renderer: Renderer!

  override func viewDidLoad() {
    super.viewDidLoad()

//    metalView.device = MTLCreateSystemDefaultDevice()
//    device = metalView.device
//
//    renderer = Renderer(device: device)
//    metalView.delegate = renderer
//
//    commandQueue = device.makeCommandQueue()

    // retrieve the SCNView
    let scnView = self.view as! SCNView

    // create a new scene
    let scene = ShaderScene(device: scnView.device!)

    // create and add a camera to the scene
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    scene.rootNode.addChildNode(cameraNode)

    // place the camera
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)

    // create and add a light to the scene
    let lightNode = SCNNode()
    lightNode.light = SCNLight()
    lightNode.light!.type = .omni
    lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
    scene.rootNode.addChildNode(lightNode)

    // create and add an ambient light to the scene
    let ambientLightNode = SCNNode()
    ambientLightNode.light = SCNLight()
    ambientLightNode.light!.type = .ambient
    ambientLightNode.light!.color = UIColor.darkGray
    scene.rootNode.addChildNode(ambientLightNode)



    // set the scene to the view
    scnView.scene = scene



    // allows the user to manipulate the camera
    scnView.allowsCameraControl = true

    // show statistics such as fps and timing information
    scnView.showsStatistics = true

    // configure the view
    scnView.backgroundColor = UIColor.black

//    // add a tap gesture recognizer
//    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//    scnView.addGestureRecognizer(tapGesture)
  }
}

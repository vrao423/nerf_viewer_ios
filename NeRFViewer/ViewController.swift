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

//  var renderer: Renderer!

  let camera = SCNCamera()

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
    scnView.delegate = self
    // create a new scene
    let scene = ShaderScene(device: scnView.device!)

//    gCamera = new THREE.PerspectiveCamera(
//        72, canvas.offsetWidth / canvas.offsetHeight, gNearPlane, 100.0);
//    gCamera.aspect = view.offsetWidth / view.offsetHeight;
//    gCamera.fov = vfovy;

    // create and add a camera to the scene
    let cameraNode = SCNNode()
    cameraNode.camera = camera
    cameraNode.camera?.zNear = 0.33
    cameraNode.camera?.zFar = 100.0
    cameraNode.camera?.fieldOfView = 35
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

extension ViewController: SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
    let world_T_clip = SCNMatrix4Invert(camera.projectionTransform)
    
    
    


//    let world_T_camera = gCamera.matrixWorld;
//    let camera_T_clip = new THREE.Matrix4();
//    camera_T_clip.getInverse(gCamera.projectionMatrix);
//    let world_T_clip = new THREE.Matrix4();
//    world_T_clip.multiplyMatrices(world_T_camera, camera_T_clip);

  }
}

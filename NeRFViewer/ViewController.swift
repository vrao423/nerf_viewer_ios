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
  var shaderScene: ShaderScene! = nil

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
    shaderScene = ShaderScene(device: scnView.device!)

    // create and add a camera to the scene
    let cameraNode = SCNNode()
    cameraNode.camera = camera
    cameraNode.camera?.zNear = 0.33
    cameraNode.camera?.zFar = 100.0
    cameraNode.camera?.fieldOfView = 35
    shaderScene.rootNode.addChildNode(cameraNode)

    // place the camera
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)

    // create and add a light to the scene
    let lightNode = SCNNode()
    lightNode.light = SCNLight()
    lightNode.light!.type = .omni
    lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
    shaderScene.rootNode.addChildNode(lightNode)

    // create and add an ambient light to the scene
    let ambientLightNode = SCNNode()
    ambientLightNode.light = SCNLight()
    ambientLightNode.light!.type = .ambient
    ambientLightNode.light!.color = UIColor.darkGray
    shaderScene.rootNode.addChildNode(ambientLightNode)

    // set the scene to the view
    scnView.scene = shaderScene

    // allows the user to manipulate the camera
    scnView.allowsCameraControl = true

    // show statistics such as fps and timing information
    scnView.showsStatistics = true

    // configure the view
    scnView.backgroundColor = UIColor.green

  }
}

extension ViewController: SCNSceneRendererDelegate {
//  func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
//    let projectionTransform = camera.projectionTransform
//    let world_T_clip = SCNMatrix4Invert(camera.projectionTransform)
//    shaderScene.world_T_clip = world_T_clip
//  }
//
//  func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
//    let scnView = self.view as! SCNView
//    let device = scnView.device
//    guard let encoder = scnView.currentRenderCommandEncoder else { return }
//    let projectionTransform = camera.projectionTransform
//    let world_T_clip = SCNMatrix4Invert(camera.projectionTransform)
//    shaderScene.world_T_clip = world_T_clip
//
//    var vertexConstants =  VertexConstants(world_T_clip: simd_float4x4(world_T_clip))
//    let mtlBuffer = device!.makeBuffer(bytes: &vertexConstants, length: MemoryLayout<VertexConstants>.stride, options: .cpuCacheModeWriteCombined)
//    encoder.setVertexBuffer(mtlBuffer, offset: 0, index: 2)
//
//  }
}

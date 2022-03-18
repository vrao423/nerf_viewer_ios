import SceneKit

final class ShaderScene: SCNScene {
  let node: NeRFNode

  init(device: MTLDevice, width: Int, height: Int) {
    node = NeRFNode(device: device, width: width, height: height)
    super.init()
    rootNode.addChildNode(node)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

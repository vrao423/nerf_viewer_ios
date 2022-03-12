//
//  ShaderScene.swift
//  NeRFViewer
//
//  Created by Venkat Rao on 3/11/22.
//

import SceneKit

final class ShaderScene: SCNScene {
  override init() {
    super.init()
    
    let node = SCNNode()
    node.castsShadow = false
    node.position = SCNVector3(0, 0, 0)
    node.geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
    rootNode.addChildNode(node)

    let program = SCNProgram()
    program.vertexFunctionName = "textureSamplerVertex"
    program.fragmentFunctionName = "textureSamplerFragment"
    node.geometry?.firstMaterial?.program = program

    guard let landscapeImage  = UIImage(named: "shrek") else {
      return
    }
    let materialProperty = SCNMaterialProperty(contents: landscapeImage)
    node.geometry?.firstMaterial?.setValue(materialProperty, forKey: "customTexture")
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

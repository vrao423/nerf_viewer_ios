//
//  NeRFNode.swift
//  NeRFViewer
//
//  Created by Venkat Rao on 3/11/22.
//

import SceneKit

class NeRFNode: SCNNode {
  override init() {
    super.init()

    self.castsShadow = false
    self.position = SCNVector3(0, 0, 0)
    self.geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)

    let program = SCNProgram()
    program.vertexFunctionName = "textureSamplerVertex"
    program.fragmentFunctionName = "textureSamplerFragment"
    program.isOpaque = false
    self.geometry?.firstMaterial?.program = program

    guard let landscapeImage  = UIImage(named: "shrek") else {
      return
    }
    let materialProperty = SCNMaterialProperty(contents: landscapeImage)
    self.geometry?.firstMaterial?.setValue(materialProperty, forKey: "customTexture")
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

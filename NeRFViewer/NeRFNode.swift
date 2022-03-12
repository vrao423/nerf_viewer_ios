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
    program.vertexFunctionName = "vertex_shader"
    program.fragmentFunctionName = "fragment_shader"
    program.isOpaque = false
    self.geometry?.firstMaterial?.program = program

    guard let landscapeImage  = UIImage(named: "shrek") else {
      return
    }
    let materialProperty = SCNMaterialProperty(contents: landscapeImage)

    let fragmentConstants = FragmentConstants(animateBy: 0,
                                              bar: 0,
                                              foo: float4(1),
                                              displayMode: 0,
                                              ndc: 0, voxelSize: 10,
                                              blockSize: 100,
                                              nearPlane: 100,
                                              ndc_h: 100,
                                              ndc_w: 100,
                                              ndc_f: 100)

    self.geometry?.firstMaterial?.setValue(fragmentConstants, forKey: "fragmentConstants")
    self.geometry?.firstMaterial?.setValue(materialProperty, forKey: "mapAlpha")
    self.geometry?.firstMaterial?.setValue(materialProperty, forKey: "mapColor")
    self.geometry?.firstMaterial?.setValue(materialProperty, forKey: "mapFeatures")
    self.geometry?.firstMaterial?.setValue(materialProperty, forKey: "mapIndex")
    self.geometry?.firstMaterial?.setValue(materialProperty, forKey: "weightsZero")
    self.geometry?.firstMaterial?.setValue(materialProperty, forKey: "weightsOne")
    self.geometry?.firstMaterial?.setValue(materialProperty, forKey: "weightsTwo")


  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

//
//  NeRFNode.swift
//  NeRFViewer
//
//  Created by Venkat Rao on 3/11/22.
//

import SceneKit
import Foundation

class NeRFNode: SCNNode {

  let voxel_size: Float = 0.0024817874999999994

  let ndc_f: Float = 755.644059435;
  let ndc_w: Float = 1006.0;
  let ndc_h: Float = 756.0;

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

    var fragmentConstants = FragmentConstants(animateBy: 0,
                                              bar: 0,
                                              foo: float4(1),
                                              displayMode: 0,
                                              ndc: 0,
                                              voxelSize: voxel_size,
                                              blockSize: 100,
                                              nearPlane: 100,
                                              ndc_h: ndc_h,
                                              ndc_w: ndc_w,
                                              ndc_f: ndc_f)

    var vertexConstants = VertexConstants()

    self.geometry?.firstMaterial?.setValue(fragmentConstants.encode(), forKey: "fragmentConstants")
    self.geometry?.firstMaterial?.setValue(vertexConstants.encode(), forKey: "vertexConstants")


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

extension FragmentConstants {
  mutating func encode() -> NSData {
    return withUnsafePointer(to: &self) { p in
        NSData(bytes: p, length: MemoryLayout<FragmentConstants>.stride)
      }
  }
}

extension VertexConstants {
  mutating func encode() -> NSData {
    return withUnsafePointer(to: &self) { p in
        NSData(bytes: p, length: MemoryLayout<VertexConstants>.stride)
      }
  }
}


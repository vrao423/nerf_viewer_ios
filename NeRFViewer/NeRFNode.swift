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

  override init(objectName: String) {
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

    let dataLoader = DataLoader(name: "logo")

    var vertexConstants = VertexConstants()

    self.geometry?.firstMaterial?.setValue(dataLoader.fragmentConstants.encode(), forKey: "fragmentConstants")
    self.geometry?.firstMaterial?.setValue(vertexConstants.encode(), forKey: "vertexConstants")

    self.geometry?.firstMaterial?.setValue(dataLoader.mapAlpha, forKey: "mapAlpha")
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






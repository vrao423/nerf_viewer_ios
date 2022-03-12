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

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

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

    guard let dataLoader = DataLoader(name: "objectName") else {
      return
    }

    self.geometry?.firstMaterial?.setValue(dataLoader.fragmentConstants.encode(), forKey: "fragmentConstants")
    self.geometry?.firstMaterial?.setValue(dataLoader.vertexConstants.encode(), forKey: "vertexConstants")

    self.geometry?.firstMaterial?.setValue(dataLoader.mapAlpha, forKey: "mapAlpha")
    self.geometry?.firstMaterial?.setValue(dataLoader.mapColor, forKey: "mapColor")
    self.geometry?.firstMaterial?.setValue(dataLoader.mapFeatures, forKey: "mapFeatures")
    self.geometry?.firstMaterial?.setValue(dataLoader.mapIndex, forKey: "mapIndex")
    self.geometry?.firstMaterial?.setValue(dataLoader.weightsZero, forKey: "weightsZero")
    self.geometry?.firstMaterial?.setValue(dataLoader.weightsOne, forKey: "weightsOne")
    self.geometry?.firstMaterial?.setValue(dataLoader.weightsTwo, forKey: "weightsTwo")
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






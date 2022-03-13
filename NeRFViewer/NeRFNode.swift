import SceneKit
import Foundation

class NeRFNode: SCNNode {

  let voxel_size: Float = 0.0024817874999999994

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  init(geometry: SCNGeometry?) {
    fatalError("init(coder:) has not been implemented")
  }

  init(device: MTLDevice) {
    super.init()
    let width = 1280;
    let height = 720;

    self.castsShadow = false
    
    // Create a plane geometry with width * height vertices.
    let plane = SCNPlane(width: CGFloat(width), height: CGFloat(height));
    plane.widthSegmentCount = width;
    plane.heightSegmentCount = height;
    self.geometry = plane;
    
    let program = SCNProgram()
    program.vertexFunctionName = "vertex_shader"
    program.fragmentFunctionName = "fragment_shader"
    program.isOpaque = false
    self.geometry?.firstMaterial?.program = program

    guard let dataLoader = DataLoader(name: "lego", device: device) else {
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






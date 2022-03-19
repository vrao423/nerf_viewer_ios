import SceneKit
import Foundation

class NeRFNode: SCNNode {

  let voxel_size: Float = 0.0024817874999999994
  var dataLoader: DataLoader?

  var vertexConstantsData: Data?
  var fragmentConstantsData: Data?

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  init(geometry: SCNGeometry?) {
    fatalError("init(coder:) has not been implemented")
  }

  init(device: MTLDevice, width: Int, height: Int) {
    super.init()

    self.castsShadow = false
    
    // Create a plane geometry with width * height vertices.
    let plane = SCNPlane(width: CGFloat(width), height: CGFloat(height));
//    plane.widthSegmentCount = Int(width);
//    plane.heightSegmentCount = Int(height);
    self.geometry = plane;
    
    let program = SCNProgram()
    program.vertexFunctionName = "vertex_shader"
    program.fragmentFunctionName = "fragment_shader"
    program.isOpaque = false
    self.geometry?.firstMaterial?.program = program

    let blitTransform = SCNMatrix4Mult(
      makeOrthographicMatrix(left: Float(width) / -2, right: Float(width) / 2, bottom: Float(height) / -2, top: Float(height) / 2, near: -10000, far: 10000),
      SCNMatrix4Invert(SCNMatrix4MakeTranslation(0,0,100)))
    var vertexConstants = VertexConstants(blit_transform: float4x4(blitTransform))
    
    
    guard let dataLoader = DataLoader(name: "chair", device: device) else {
      return
    }

//    program.handleBinding(ofBufferNamed: "vertexConstants", frequency: .perFrame) { (bufferStream, node, shadable, renderer) in
//      bufferStream.writeBytes(&dataLoader.vertexConstants, count: MemoryLayout<VertexConstants>.stride)
//    }

    program.delegate = self

    self.dataLoader = dataLoader
    dataLoader.fragmentConstants.renderAreaSize = float2(Float(width), Float(height))
    vertexConstantsData = vertexConstants.encode()
    fragmentConstantsData = dataLoader.fragmentConstants.encode()

    self.geometry?.firstMaterial?.setValue(fragmentConstantsData!, forKey: "fragmentConstants")
    self.geometry?.firstMaterial?.setValue(vertexConstantsData!, forKey: "vertexConstants")

    self.geometry?.firstMaterial?.setValue(dataLoader.mapAlpha, forKey: "mapAlpha")
    self.geometry?.firstMaterial?.setValue(dataLoader.mapColor, forKey: "mapColor")
    self.geometry?.firstMaterial?.setValue(dataLoader.mapFeatures, forKey: "mapFeatures")
    self.geometry?.firstMaterial?.setValue(dataLoader.mapIndex, forKey: "mapIndex")
    self.geometry?.firstMaterial?.setValue(dataLoader.weightsZero, forKey: "weightsZero")
    self.geometry?.firstMaterial?.setValue(dataLoader.weightsOne, forKey: "weightsOne")
    self.geometry?.firstMaterial?.setValue(dataLoader.weightsTwo, forKey: "weightsTwo")
  }
  
  func makeOrthographicMatrix(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> SCNMatrix4 {
      return SCNMatrix4(
        m11: 2 / (right - left), m12: 0, m13: 0, m14: 0,
        m21: 0, m22: 2 / (top - bottom), m23: 0, m24: 0,
        m31: 0, m32: 0, m33: 1 / (far - near), m34: 0,
        m41: (left + right) / (left - right), m42: (top + bottom) / (bottom - top), m43: near / (near - far), m44: 1
      )
  }
}

extension FragmentConstants {
  mutating func encode() -> Data {
    return withUnsafePointer(to: &self) { p in
        Data(bytes: p, count: MemoryLayout<FragmentConstants>.stride)
      }
  }
}

extension VertexConstants {
  mutating func encode() -> Data {
    return Data(bytes: &self, count: MemoryLayout<VertexConstants>.stride)
  }
}

extension NeRFNode: SCNProgramDelegate {
  func program(_ program: SCNProgram, handleError error: Error) {
    print("error: \(error)")
  }
}

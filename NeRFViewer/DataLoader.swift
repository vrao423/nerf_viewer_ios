import Foundation
import UIKit
import simd
import SceneKit

let ndc_f: Float = 755.644059435;
let ndc_w: Float = 1006.0;
let ndc_h: Float = 756.0;

class DataLoader {

  var fragmentConstants: FragmentConstants
  var vertexConstants: VertexConstants

  var mapAlpha: SCNMaterialProperty!
  var mapColor: SCNMaterialProperty!
  var mapFeatures: SCNMaterialProperty!
  var mapIndex: SCNMaterialProperty!
  var weightsZero: SCNMaterialProperty!
  var weightsOne: SCNMaterialProperty!
  var weightsTwo: SCNMaterialProperty!
  
  func loadSplitVolumeTexturePNG(pngName: String, num_slices: Int,
                                 volume_width: Int, volume_height: Int, volume_depth: Int) {
    let slice_depth = 4;

    var rgbaPixels:Array = Array<UInt8>()
    var alphaPixels:Array = Array<UInt8>()

    for i in 0..<num_slices {
      // loadPNG should return an array of bytes (uint8).
      let rgbaPath = pngName + "_00" + String(i) + ".png"
      let rgbaImage = loadImage(name:rgbaPath)

      let rgbaSize = volume_width * volume_height * slice_depth * 4
      let alphaSize = volume_width * volume_height * slice_depth * 1
      
      var rgbaPixelsSlice: [UInt8] = [UInt8](repeating: 0, count: rgbaSize)
      var alphaPixelsSlice: [UInt8] = [UInt8](repeating: 0, count: alphaSize)
    
      print("loadSplitVolumeTexturePNG loading: ", i)

      for j in 0..<volume_width * volume_height * slice_depth {
        rgbaPixelsSlice[j * 4 + 0] = rgbaImage[j * 4 + 0]
        rgbaPixelsSlice[j * 4 + 1] = rgbaImage[j * 4 + 1]
        rgbaPixelsSlice[j * 4 + 2] = rgbaImage[j * 4 + 2]
        rgbaPixelsSlice[j * 4 + 3] = rgbaImage[j * 4 + 3]
        alphaPixelsSlice[j] = rgbaImage[j * 4 + 3]
      }
      rgbaPixels.append(contentsOf: rgbaPixelsSlice)
      alphaPixels.append(contentsOf: alphaPixelsSlice)
    }
    self.mapColor = make3DSCNMaterialProperty(data:rgbaPixels, pixelFormat:4, volume_width: volume_width, volume_height: volume_height, volume_depth: volume_depth)
    self.mapAlpha = make3DSCNMaterialProperty(data:alphaPixels, pixelFormat:1, volume_width: volume_width, volume_height: volume_height, volume_depth: volume_depth)
  }

  func loadVolumeTexturePNG(pngName: String, num_slices: Int,
                            volume_width: Int, volume_height: Int, volume_depth: Int) {
    var rgbaPixels:Array = Array<UInt8>()

    for i in 0..<num_slices {
      print("loadVolumeTexturePNG loading :", i)
      // loadPNG should return an array of bytes (uint8).
      let rgbaPath = pngName + "_00" + String(i) + ".png"
      let rgbaPixelsSlice = loadImage(name:rgbaPath)

      rgbaPixels.append(contentsOf: rgbaPixelsSlice)
    }
    self.mapFeatures = make3DSCNMaterialProperty(data:rgbaPixels, pixelFormat:4, volume_width: volume_width, volume_height: volume_height, volume_depth: volume_depth)
  }

  func make3DSCNMaterialProperty (data: Array<UInt8>, pixelFormat: Int, volume_width: Int,
                                  volume_height: Int, volume_depth: Int) -> SCNMaterialProperty {
    let textureDescriptor = MTLTextureDescriptor()
    if (pixelFormat == 4) {
      textureDescriptor.pixelFormat = MTLPixelFormat.rgba8Uint
    } else if (pixelFormat == 1) {
      textureDescriptor.pixelFormat = MTLPixelFormat.r8Uint
    }
    textureDescriptor.textureType = MTLTextureType.type3D
    textureDescriptor.width = volume_width
    textureDescriptor.height = volume_height
    textureDescriptor.depth = volume_depth

    let device = MTLCreateSystemDefaultDevice()
    let texture = device?.makeTexture(descriptor: textureDescriptor)
    texture?.replace(region: MTLRegionMake3D(0, 0, 0, volume_width, volume_height, volume_depth),
                            mipmapLevel:0,
                            slice:0,
                            withBytes:data,
                            bytesPerRow:volume_width * pixelFormat * MemoryLayout<UInt8>.size,
                            bytesPerImage:volume_width * volume_height * pixelFormat * MemoryLayout<UInt8>.size)
    let materialProp = SCNMaterialProperty()
    materialProp.contents = texture

    return materialProp
  }

  init?(name: String, device: MTLDevice) {

    let sceneParams:[String: Any] = readSceneParams()

    let gridSize = float3( (sceneParams["grid_width"] as! NSNumber).floatValue,
                           (sceneParams["grid_height"] as! NSNumber).floatValue,
                           (sceneParams["grid_depth"] as! NSNumber).floatValue)

    let atlasSize = float3( (sceneParams["atlas_width"] as! NSNumber).floatValue,
                           (sceneParams["atlas_height"] as! NSNumber).floatValue,
                           (sceneParams["atlas_depth"] as! NSNumber).floatValue)

    let worldspace_T_opengl = sceneParams["worldspace_T_opengl"] as! [[NSNumber]]
    let worldspace_R_opengl = float3x3(SIMD3<Float>(worldspace_T_opengl[0][0].floatValue, worldspace_T_opengl[0][1].floatValue, worldspace_T_opengl[0][2].floatValue),
                                       SIMD3<Float>(worldspace_T_opengl[1][0].floatValue, worldspace_T_opengl[1][1].floatValue, worldspace_T_opengl[1][2].floatValue),
                                       SIMD3<Float>(worldspace_T_opengl[2][0].floatValue, worldspace_T_opengl[2][1].floatValue, worldspace_T_opengl[2][2].floatValue))

    let minPosition =  float3( (sceneParams["min_x"] as! NSNumber).floatValue,
                               (sceneParams["min_y"] as! NSNumber).floatValue,
                               (sceneParams["min_z"] as! NSNumber).floatValue)

    self.fragmentConstants = FragmentConstants(displayMode: 0,
                                               ndc: (sceneParams["ndc"] as! Int),
                                               minPosition: minPosition,
                                               gridSize: gridSize,
                                               atlasSize: atlasSize,
                                               voxelSize: (sceneParams["voxel_size"] as! NSNumber).floatValue,
                                               blockSize: (sceneParams["block_size"] as! NSNumber).floatValue,
                                               worldspace_R_opengl: worldspace_R_opengl,
                                               nearPlane: 0.33, // 686
                                               ndc_h: ndc_h,
                                               ndc_w: ndc_w,
                                               ndc_f: ndc_f)

    let world_T_clip: float4x4 = float4x4(2);
    self.vertexConstants = VertexConstants(world_T_clip: world_T_clip)

    let numSlices = sceneParams["num_slices"] as! Int

    loadScene(device: device, dirUrl: "lego", width: 1280, height: 720)
  }

  func loadScene(device: MTLDevice, dirUrl: String, width: Int, height: Int) {
    
    var sceneParams:[String: Any] = readSceneParams()

    sceneParams["dirUrl"] = dirUrl
    sceneParams["loadingTextures"] = false
    sceneParams["diffuse"] = true
    
    let numTextures = sceneParams["num_slices"]

    let atlasIndexImage = loadImage(name: "lego/atlas_indices.png")

    let atlasIndexTextureDescriptor = MTLTextureDescriptor()
    atlasIndexTextureDescriptor.pixelFormat = .rgba8Uint
    atlasIndexTextureDescriptor.textureType = .type3D
    atlasIndexTextureDescriptor.width = Int(ceil((sceneParams["grid_width"] as! NSNumber).floatValue / (sceneParams["block_size"] as! NSNumber).floatValue))
    atlasIndexTextureDescriptor.height = Int(ceil((sceneParams["grid_height"] as! NSNumber).floatValue / (sceneParams["block_size"] as! NSNumber).floatValue))
    atlasIndexTextureDescriptor.depth = Int(ceil((sceneParams["grid_depth"] as! NSNumber).floatValue / (sceneParams["block_size"] as! NSNumber).floatValue))
    let atlasIndexTexture = device.makeTexture(descriptor: atlasIndexTextureDescriptor)
    
    // Create a 3D texture for atlasIndexTexture.
    atlasIndexTexture!.replace(region: MTLRegionMake3D(0, 0, 0, atlasIndexTextureDescriptor.width,  atlasIndexTextureDescriptor.height, atlasIndexTextureDescriptor.depth),
                               mipmapLevel:0,
                               slice:0,
                               withBytes:atlasIndexImage,
                               bytesPerRow:atlasIndexTextureDescriptor.width * 4 * MemoryLayout<UInt8>.size,
                               bytesPerImage: atlasIndexTextureDescriptor.width * atlasIndexTextureDescriptor.height * 4 * MemoryLayout<UInt8>.size)
    self.mapIndex = SCNMaterialProperty(contents: atlasIndexTexture)

    createRayMarchMaterial(sceneParams: sceneParams)
  }

  func createRayMarchMaterial(sceneParams: [String: Any]) -> DataLoader? {
    let atlas_width = (sceneParams["atlas_width"] as! Int)
    let atlas_height = (sceneParams["atlas_height"] as! Int)
    let atlas_depth = (sceneParams["atlas_depth"] as! Int)

    let numSlices = sceneParams["num_slices"] as! Int

    loadSplitVolumeTexturePNG(pngName: "lego/feature", num_slices: numSlices,
                                   volume_width: atlas_width, volume_height: atlas_height, volume_depth: atlas_depth)

    loadVolumeTexturePNG(pngName: "lego/rgba", num_slices: numSlices,
                              volume_width: atlas_width, volume_height: atlas_height, volume_depth: atlas_depth)

    return nil
  }
}

func readSceneParams() -> [String : Any] {
  let path = Bundle.main.path(forResource: "lego/scene_params", ofType: "json")
  let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path!))
  let jsonResult:[String: Any] = try! JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as! [String : Any]
  return jsonResult
}

func loadImage(name: String) -> [UInt8] {
  let image = UIImage(named: name)!
  var imageInts: [UInt8] = []
  guard let cgImage = image.cgImage,
        let data = cgImage.dataProvider?.data,
        let bytes = CFDataGetBytePtr(data) else {
          fatalError("Couldn't access image data")
        }

  let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
  for y in 0 ..< cgImage.height {
    for x in 0 ..< cgImage.width {
      let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
      imageInts.append(contentsOf: [bytes[offset], bytes[offset + 1], bytes[offset + 2], bytes[offset + 3]])
    }
  }

  return imageInts
}

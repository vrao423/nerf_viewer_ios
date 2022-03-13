//
//  DataLoader.swift
//  NeRFViewer
//
//  Created by Venkat Rao on 3/11/22.
//

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

//      var rgbaPixelsSlice:Array = Array<UInt8>()
//      var alphaPixelsSlice:Array = Array<UInt8>()
      
      let rgbaSize = volume_width * volume_height * slice_depth * 4
      let alphaSize = volume_width * volume_height * slice_depth * 1
      
      var rgbaPixelsSlice: [UInt8] = [UInt8](repeating: 0, count: rgbaSize)
      var alphaPixelsSlice: [UInt8] = [UInt8](repeating: 0, count: alphaSize)
      
      
      print("rgbaImage size: ", rgbaImage.count)
      print("volume_width * volume_height * slice_depth = ", volume_width * volume_height * slice_depth)

      for j in 0..<volume_width * volume_height * slice_depth {
        rgbaPixelsSlice[j * 4 + 0] = rgbaImage[j * 4 + 0]
        rgbaPixelsSlice[j * 4 + 1] = rgbaImage[j * 4 + 1]
        rgbaPixelsSlice[j * 4 + 2] = rgbaImage[j * 4 + 2]
        rgbaPixelsSlice[j * 4 + 3] = rgbaImage[j * 4 + 3]
        alphaPixelsSlice[j] = rgbaImage[j * 4 + 3]
//        rgbaPixelsSlice[j * 4 + 0] = 200
//        rgbaPixelsSlice[j * 4 + 1] = 100
//        rgbaPixelsSlice[j * 4 + 2] = 180
//        rgbaPixelsSlice[j * 4 + 3] = 100
//        alphaPixelsSlice[j] = 100
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
//    let buffer = device?.makeBuffer(length: data.count, options: MTLResourceOptions.storageModeShared)

//    for pixelInfo in data {
//      buffer?.contents().storeBytes(of: pixelInfo, as: UInt8.self)
//    }
//
//    let texture = buffer?.makeTexture(descriptor: textureDescriptor,offset:0, bytesPerRow: data.count)
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

    self.vertexConstants = VertexConstants()

    let numSlices = sceneParams["num_slices"] as! Int

//    for i in 0..<numSlices {
//      loadImage(name: "lego/rgba_00\(i).png")
//    }

    // ???
//    guard let landscapeImage  = UIImage(named: "shrek") else {
//      return nil
//    }
//
//    let materialProperty = SCNMaterialProperty(contents: landscapeImage)
//    self.weightsZero = materialProperty
//    self.weightsOne = materialProperty
//    self.weightsTwo = materialProperty
    // ???

    loadScene(device: device, dirUrl: "lego", width: 1280, height: 720)
  }

  func loadScene(device: MTLDevice, dirUrl: String, width: Int, height: Int) {
  //  // Reset the texture loading window.
  //  gLoadedRGBATextures = gLoadedFeatureTextures = gNumTextures = 0;
  //  updateLoadingProgress();

    var sceneParams:[String: Any] = readSceneParams()

  //
  //    // Start rendering ASAP, forcing THREE.js to upload the textures.
  //    requestAnimationFrame(render);
  //
    sceneParams["dirUrl"] = dirUrl
    sceneParams["loadingTextures"] = false
    sceneParams["diffuse"] = true
    // If we have a view-dependence network in the json file, turn on view
    // dependence.
  //  if ('0_bias' in gSceneParams) {
  //    gSceneParams['diffuse'] = false;
  //  }
    let numTextures = sceneParams["num_slices"]

  //    let atlasIndexTexture = new THREE.DataTexture3D(
  //        atlasIndexImage,
  //        Math.ceil(gSceneParams['grid_width'] / gSceneParams['block_size']),
  //        Math.ceil(gSceneParams['grid_height'] / gSceneParams['block_size']),
  //        Math.ceil(gSceneParams['grid_depth'] / gSceneParams['block_size']));
  //    atlasIndexTexture.format = THREE.RGBAFormat;
  //    atlasIndexTexture.generateMipmaps = false;
  //    atlasIndexTexture.magFilter = atlasIndexTexture.minFilter =
  //        THREE.NearestFilter;
  //    atlasIndexTexture.wrapS = atlasIndexTexture.wrapT =
  //        atlasIndexTexture.wrapR = THREE.ClampToEdgeWrapping;
  //    atlasIndexTexture.type = THREE.UnsignedByteType;

    // Set up atlasIndex (mapIndex)
    let atlasIndexImage = loadImage(name: "lego/atlas_indices.png")
    let atlas_width = (sceneParams["atlas_width"] as! Int)
    let atlas_height = (sceneParams["atlas_height"] as! Int)
    let atlas_depth = (sceneParams["atlas_depth"] as! Int)

    let atlasIndexTextureDescriptor = MTLTextureDescriptor()
    atlasIndexTextureDescriptor.pixelFormat = .rgba8Uint
    atlasIndexTextureDescriptor.textureType = .type3D
    atlasIndexTextureDescriptor.width = Int((sceneParams["atlas_width"] as! NSNumber).floatValue / (sceneParams["block_size"] as! NSNumber).floatValue)
    atlasIndexTextureDescriptor.height = Int((sceneParams["atlas_height"] as! NSNumber).floatValue / (sceneParams["block_size"] as! NSNumber).floatValue)
    atlasIndexTextureDescriptor.depth = Int((sceneParams["atlas_depth"] as! NSNumber).floatValue / (sceneParams["block_size"] as! NSNumber).floatValue)
    let atlasIndexTexture = device.makeTexture(descriptor: atlasIndexTextureDescriptor)
    
    let mywidth = ((sceneParams["grid_width"] as! Int) / (sceneParams["block_size"] as! Int))
    print("atlasIndexTextureDescriptor WIDTH:", mywidth)
    
    print("grid_width: " ,sceneParams["grid_width"])
    print("block_size: " ,sceneParams["block_size"])
    
    
    
    print("atlasIndexTextureDescriptor.width", atlasIndexTextureDescriptor.width)
    print("atlasIndexTextureDescriptor.height", atlasIndexTextureDescriptor.height)
    atlasIndexTexture!.replace(region: MTLRegionMake3D(0, 0, 0, atlasIndexTextureDescriptor.width,  atlasIndexTextureDescriptor.height, atlasIndexTextureDescriptor.depth),
                               mipmapLevel:0,
                               withBytes:atlasIndexImage,
                               bytesPerRow:atlasIndexTextureDescriptor.width * 4 * MemoryLayout<UInt8>.size)
    self.mapIndex = SCNMaterialProperty(contents: atlasIndexTexture)

    createRayMarchMaterial(sceneParams: sceneParams)
  }
  
  

  func createRayMarchMaterial(sceneParams: [String: Any]) -> DataLoader? {

    let minPosition: float3 = float3((sceneParams["min_x"] as! NSNumber).floatValue,
                                     (sceneParams["min_y"] as! NSNumber).floatValue,
                                     (sceneParams["min_z"] as! NSNumber).floatValue)

    let gridWidth = (sceneParams["grid_width"] as! NSNumber).floatValue
    let grid_height = (sceneParams["grid_height"] as! NSNumber).floatValue
    let grid_depth = (sceneParams["grid_depth"] as! NSNumber).floatValue
    let block_size = (sceneParams["block_size"] as! NSNumber).floatValue
    let voxel_size = (sceneParams["voxel_size"] as! NSNumber).floatValue
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

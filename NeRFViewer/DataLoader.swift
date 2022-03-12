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

  let mapAlpha: SCNMaterialProperty
  let mapColor: SCNMaterialProperty
  let mapFeatures: SCNMaterialProperty
  let mapIndex: SCNMaterialProperty
  let weightsZero: SCNMaterialProperty
  let weightsOne: SCNMaterialProperty
  let weightsTwo: SCNMaterialProperty
  
  func loadSplitVolumeTexturePNG(pngName: String, num_slices: Int,
                                 volume_width: Int, volume_height: Int, volume_depth: Int) {
    let slice_depth = 4;
    
    var rgbPixels:Array = Array<UInt8>()
    var alphaPixels:Array = Array<UInt8>()
    
    for i in 0..<num_slices {
      // loadPNG should return an array of bytes (uint8).
      let rgbaPath = pngName + "_00" + String(i) + ".png"
      let rgbaPixels = loadImage(name:rgbaPath)
      
      var rgbPixelsSlice:Array = Array<UInt8>()
      var alphaPixelsSlice:Array = Array<UInt8>()
      
      for j in 0..<volume_width * volume_height * slice_depth {
        rgbPixelsSlice[j * 3 + 0] = rgbaPixels[j * 4 + 0]
        rgbPixelsSlice[j * 3 + 1] = rgbaPixels[j * 4 + 1]
        rgbPixelsSlice[j * 3 + 2] = rgbaPixels[j * 4 + 2]
        alphaPixelsSlice[j] = rgbaPixels[j * 4 + 3]
      }
      rgbPixels.append(contentsOf: rgbPixelsSlice)
      alphaPixels.append(contentsOf: alphaPixelsSlice)
    }
    self.mapColor = make3DSCNMaterialProperty(data:rgbPixels, volume_width: volume_width, volume_height: volume_height, volume_depth: volume_depth)
    self.mapAlpha = make3DSCNMaterialProperty(data:alphaPixels, volume_width: volume_width, volume_height: volume_height, volume_depth: volume_depth)
  }
  
  func make3DSCNMaterialProperty (data: Array<UInt8>, volume_width: Int,
                                  volume_height: Int, volume_depth: Int) -> SCNMaterialProperty {
    let textureDescriptor = MTLTextureDescriptor()
    textureDescriptor.textureType = MTLTextureType.type3D
    textureDescriptor.pixelFormat = MTLPixelFormat.r8Uint // Not sure...
    textureDescriptor.width = volume_width
    textureDescriptor.height = volume_height
    textureDescriptor.depth = volume_depth
    
    let device = MTLCreateSystemDefaultDevice()
    let buffer = device?.makeBuffer(length: data.count, options: MTLResourceOptions.storageModeShared)
    
    for pixelInfo in data {
      buffer?.contents().storeBytes(of: pixelInfo, as: UInt8.self)
    }
    
    let texture = buffer?.makeTexture(descriptor: textureDescriptor,offset:0, bytesPerRow: data.count)
    
    let materialProp = SCNMaterialProperty()
    materialProp.contents = texture
    
    return materialProp
  }
  
  init?(name: String) {
    let jsonResult:[String: Any] = readSceneParams()

    self.fragmentConstants = FragmentConstants(animateBy: 0,
                                               bar: 0,
                                               foo: float4(1),
                                               displayMode: 0,
                                               ndc: 0,
                                               voxelSize: (jsonResult["voxel_size"] as! NSNumber).floatValue,
                                               blockSize: (jsonResult["block_size"] as! NSNumber).floatValue,
                                               nearPlane: 100,
                                               ndc_h: ndc_h,
                                               ndc_w: ndc_w,
                                               ndc_f: ndc_f)

    self.vertexConstants = VertexConstants()

    let numSlices = jsonResult["num_slices"] as! Int

    for i in 0..<numSlices {
      loadImage(name: "lego/rgba_00\(i).png")
    }

    guard let landscapeImage  = UIImage(named: "shrek") else {
      return nil
    }
    
    let materialProperty = SCNMaterialProperty(contents: landscapeImage)

    let rgbVolumeTextureDescriptor = MTLTextureDescriptor()
    rgbVolumeTextureDescriptor.pixelFormat = .etc2_rgb8
    rgbVolumeTextureDescriptor.textureType = .type3D
    rgbVolumeTextureDescriptor.width = jsonResult["atlas_width"] as! Int
    rgbVolumeTextureDescriptor.height = jsonResult["atlas_height"] as! Int
    rgbVolumeTextureDescriptor.depth = jsonResult["atlas_depth"] as! Int


    self.mapAlpha = materialProperty
    self.mapColor = materialProperty
    self.mapFeatures = materialProperty
    self.mapIndex = materialProperty
    self.weightsZero = materialProperty
    self.weightsOne = materialProperty
    self.weightsTwo = materialProperty

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

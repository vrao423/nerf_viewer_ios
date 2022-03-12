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
  
  func loadSplitVolumeTexturePNG(pngName: String, num_slices: Int, volume_width: Int, volume_height: Int) {
    let slice_depth = 4;
    
    var rgbPixels:Array = Array<UInt8>()
    var alphaPixels:Array = Array<UInt8>()
    
    for i in 0..<num_slices {
      // loadPNG should return an array of bytes (uint8).
      let rgbaPath = pngName + "_00" + String(i) + ".png"
      let rgbaPixels = loadPNG(rgbaPath)
      
      var rgbPixelsSlice:Array = Array<UInt8>()
      var alphaPixelsSlice:Array = Array<UInt8>()
      
      for j in 0..<volume_width * volume_height * slice_depth {
        rgbPixelsSlice[j * 3 + 0] = rgbaPixels[j * 4 + 0]
        rgbPixelsSlice[j * 3 + 1] = rgbaPixels[j * 4 + 1]
        rgbPixelsSlice[j * 3 + 2] = rgbaPixels[j * 4 + 2]
        alphaPixelsSlice[j] = rgbaPixels[j * 4 + 3]
      }
      rgbPixels.append(contentsOf: rgbPixelsSlice)
      rgbaPixels.append(contentsOf: alphaPixelsSlice)
    }
    //mapColor = make3DSCNMaterialProperty(rgbPixels)
    //mapAlpha = make3DSCNMaterialProperty(alphaPixels)
  }
  
  //SCNMaterialProperty make3DSCNMaterialProperty

  
  init?(name: String) {

    let path = Bundle.main.path(forResource: "lego/scene_params", ofType: "json")
    let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path!))
    let jsonResult:[String: Any] = try! JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as! [String : Any]

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

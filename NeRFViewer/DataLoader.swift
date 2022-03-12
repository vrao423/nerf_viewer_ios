//
//  DataLoader.swift
//  NeRFViewer
//
//  Created by Venkat Rao on 3/11/22.
//

import Foundation
import UIKit
import simd

let ndc_f: Float = 755.644059435;
let ndc_w: Float = 1006.0;
let ndc_h: Float = 756.0;

class DataLoader {

  let fragmentConstants: FragmentConstants
  let vertexConstants: VertexConstants

  let mapAlpha: UIImage
  let mapColor: UIImage
  let mapFeatures: UIImage
  let mapIndex: UIImage
  let weightsZero: UIImage
  let weightsOne: UIImage
  let weightsTwo: UIImage

  init(name: String) {

    let json: [String: Float]

    fragmentConstants = FragmentConstants(animateBy: 0,
                                            bar: 0,
                                            foo: float4(1),
                                            displayMode: 0,
                                            ndc: 0,
                                            voxelSize: json["voxel_size"]!,
                                            blockSize: 100,
                                            nearPlane: 100,
                                            ndc_h: ndc_h,
                                            ndc_w: ndc_w,
                                            ndc_f: ndc_f)

    vertexConstants = VertexConstants()
  }
}

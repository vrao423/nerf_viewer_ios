//
//  Types.swift
//  BrightnessShader
//
//  Created by Venkat Rao on 3/10/22.
//

import simd

struct VertexIn {
  let position: float3
  let color: float4
  let texture: float2
}

struct VertexOut {
  let position: float3
  let color: float4
}

struct FragmentConstants {
  var animateBy: Float = 0
  
  // Stuff from the viewer shader. (Remeber to update the others)
  var displayMode: Int = 0
  var ndc: Int = 0;
  
  let minPosition: float3 = float3(0,0,0);
  let gridSize: float3 = float3(0,0,0);
  let atlasSize: float3 = float3(0,0,0);
  var voxelSize: Float = 0;
  var blockSize: Float = 0;
  let worldspace_R_opengl: float3x3 = float3x3(float3(0,0,0),float3(0,0,0),float3(0,0,0));
  var nearPlane: Float = 0;
  
  var ndc_h: Float = 0;
  var ndc_w: Float = 0;
  var ndc_f: Float = 0;
}

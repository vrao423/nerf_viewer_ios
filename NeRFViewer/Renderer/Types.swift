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

struct VertexConstants {
  let world_T_clip:float4x4 = float4x4(float4(0,0,0,0), float4(0,0,0,0), float4(0,0,0,0), float4(0,0,0,0));
}

struct FragmentConstants {  
  // Stuff from the viewer shader. (Remeber to update the others)
  var displayMode: Int = 0
  var ndc: Int = 0
  
  let minPosition: float3
  let gridSize: float3
  let atlasSize: float3
  var voxelSize: Float = 0;
  var blockSize: Float = 0;
  let worldspace_R_opengl: float3x3
  var nearPlane: Float;
  
  var ndc_h: Float;
  var ndc_w: Float;
  var ndc_f: Float;
}

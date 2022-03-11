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
}

struct VertexOut {
  let position: float3
  let color: float4
}

struct Constants {
  var animateBy: Float = 0
}

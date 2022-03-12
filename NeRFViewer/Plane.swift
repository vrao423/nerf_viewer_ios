//
//  Node.swift
//  BrightnessShader
//
//  Created by Venkat Rao on 3/9/22.
//

import MetalKit
import simd

class Plane {

  var vertices: [VertexIn] = [
    VertexIn(position: float3(-1,1,0),
             color: float4(1,0,0,1),
            texture: float2(0,1)),
    VertexIn(position: float3(-1,-1,0),
           color: float4(1,0,0,1),
             texture: float2(0,0)),
    VertexIn(position: float3(1,-1,0),
           color: float4(0,0,1,1),
             texture: float2(1,0)),
    VertexIn(position: float3(1,1,0),
           color: float4(1,0,1,1),
             texture: float2(1,1))
  ]

  var indices: [UInt16] = [
    0, 1, 2,
    2, 3, 0
  ]

  var vertexBuffer: MTLBuffer?
  var indexBuffer: MTLBuffer?

  var time: Float = 0

  init(device: MTLDevice, imageName: String) {
    buildBuffers(device: device)
  }

  private func buildBuffers(device: MTLDevice) {
    vertexBuffer = device.makeBuffer(bytes: vertices,
                                     length: vertices.count * MemoryLayout<VertexIn>.stride,
                                     options: [])

    indexBuffer = device.makeBuffer(bytes: indices,
                                    length: indices.count * MemoryLayout<UInt16>.size,
                                    options: [])
  }
}

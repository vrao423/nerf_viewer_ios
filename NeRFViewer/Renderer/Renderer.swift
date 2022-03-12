//
//  Renderer.swift
//  BrightnessShader
//
//  Created by Venkat Rao on 3/9/22.
//

import MetalKit

class Renderer: NSObject {

  let device: MTLDevice
  var commandQueue: MTLCommandQueue!

  var pipelineState: MTLRenderPipelineState!

  var time: Float = 0.0

  var place: Plane!

  var constants = Constants()

  var texture: MTLTexture?

  init(device: MTLDevice) {
    self.device = device
    commandQueue = device.makeCommandQueue()
    super.init()
    place = Plane(device: device, imageName: "shrek")
    self.texture = setTexture(device: device, imageName: "shrek")
    buildPipelineState()
  }

  func buildPipelineState() {
    let library = device.makeDefaultLibrary()
    let vertexFunction = library?.makeFunction(name: "vertex_shader")
    let fragmentFunction = library?.makeFunction(name: "fragment_shader")

    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

    let vertexDesciptor = MTLVertexDescriptor()

    vertexDesciptor.attributes[0].format = .float3
    vertexDesciptor.attributes[0].offset = 0
    vertexDesciptor.attributes[0].bufferIndex = 0

    vertexDesciptor.attributes[1].format = .float4
    vertexDesciptor.attributes[1].offset = MemoryLayout<float3>.stride
    vertexDesciptor.attributes[1].bufferIndex = 0

    vertexDesciptor.attributes[2].format = .float2
    vertexDesciptor.attributes[2].offset = MemoryLayout<float3>.stride + MemoryLayout<float4>.stride
    vertexDesciptor.attributes[2].bufferIndex = 0

    vertexDesciptor.layouts[0].stride = MemoryLayout<VertexIn>.stride

    pipelineDescriptor.vertexDescriptor = vertexDesciptor

    do {
      pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    } catch let error as NSError {
      print("error: \(error.localizedDescription)")
    }
  }
}

extension Renderer: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

  }

  func draw(in view: MTKView) {
    guard let drawable = view.currentDrawable,
          let descriptor = view.currentRenderPassDescriptor,
          let pipelineState = pipelineState else {
            return
          }
    let commandBuffer  = commandQueue.makeCommandBuffer()!

    time += 1.0 / Float(view.preferredFramesPerSecond)

    let animateBy = abs(sin(time)/2 + 0.5)
    constants.animateBy = animateBy

    let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
    commandEncoder.setRenderPipelineState(pipelineState)
    commandEncoder.setVertexBuffer(place.vertexBuffer, offset: 0, index: 0)
    commandEncoder.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)

    commandEncoder.setFragmentTexture(texture, index: 0)

    commandEncoder.drawIndexedPrimitives(type: .triangle,
                                         indexCount: place.indices.count,
                                         indexType: .uint16,
                                         indexBuffer: place.indexBuffer!,
                                         indexBufferOffset: 0)

    commandEncoder.endEncoding()
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}

extension Renderer: Texturable {

}

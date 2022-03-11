//
//  BrightnessShader.swift
//  BrightnessShader
//
//  Created by Venkat Rao on 3/8/22.
//

import Foundation
import Metal


public class Brightness {
  let pipelineState: MTLComputePipelineState

  public init(library: MTLLibrary) throws {

  }

  func encode(sourceTexture: MTLTexture, destinationTexture: MTLTexture, intensity: Float, commandBuffer: MTLCommandBuffer) {
    commandBuffer.
  }
}

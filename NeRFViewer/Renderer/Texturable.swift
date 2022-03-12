//
//  Textarable.swift
//  NeRFViewer
//
//  Created by Venkat Rao on 3/10/22.
//

import Metal
import MetalKit

protocol Texturable {
  var texture: MTLTexture? { get set }
}

extension Texturable {
  func setTexture(device: MTLDevice, imageName: String) -> MTLTexture? {
    let textureLoader = MTKTextureLoader(device: device)

    var texture: MTLTexture? = nil
    let origin = NSString(string: MTKTextureLoader.Origin.bottomLeft.rawValue)
    let textureLoaderOptions = [MTKTextureLoader.Option.origin: origin]

    if let textureURL = Bundle.main.url(forResource: imageName, withExtension: "jpeg") {
      do {
        texture = try textureLoader.newTexture(URL: textureURL, options: textureLoaderOptions)
      } catch {
        print("texture not created")
      }
    }

    return texture
  }
}

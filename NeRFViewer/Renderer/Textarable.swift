//
//  Textarable.swift
//  NeRFViewer
//
//  Created by Venkat Rao on 3/10/22.
//

import Foundation
import Metal

protocol Texturable {
  var texture: MTLTexture? { get set }
}

extension Texturable {
  func setTexture(device: MTLDevice, imageName: String) -> MTLTexture? {
    return nil
  }
}

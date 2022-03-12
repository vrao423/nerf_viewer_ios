//
//  ShaderScene.swift
//  NeRFViewer
//
//  Created by Venkat Rao on 3/11/22.
//

import SceneKit

final class ShaderScene: SCNScene {
  init(device: MTLDevice) {
    super.init()
    let node = NeRFNode(device: device)
    rootNode.addChildNode(node)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

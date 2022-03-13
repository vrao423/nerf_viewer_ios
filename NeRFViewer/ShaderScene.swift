//
//  ShaderScene.swift
//  NeRFViewer
//
//  Created by Venkat Rao on 3/11/22.
//

import SceneKit

final class ShaderScene: SCNScene {

  var world_T_clip: SCNMatrix4? {
    didSet {
      node.world_T_clip = world_T_clip
    }
  }

  let node: NeRFNode

  init(device: MTLDevice) {
    node = NeRFNode(device: device)
    super.init()
    rootNode.addChildNode(node)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

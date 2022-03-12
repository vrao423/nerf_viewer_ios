//
//  ShaderScene.swift
//  NeRFViewer
//
//  Created by Venkat Rao on 3/11/22.
//

import SceneKit

final class ShaderScene: SCNScene {
  override init() {
    super.init()
    
    let node = NeRFNode()
    rootNode.addChildNode(node)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

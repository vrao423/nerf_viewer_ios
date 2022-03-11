//
//  ViewController.swift
//  BrightnessShader
//
//  Created by Venkat Rao on 3/8/22.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

  var metalView: MTKView {
    return view as! MTKView
  }

  var device: MTLDevice!
  var commandQueue: MTLCommandQueue!

  var renderer: Renderer!

  override func viewDidLoad() {
    super.viewDidLoad()

    metalView.device = MTLCreateSystemDefaultDevice()
    device = metalView.device

    renderer = Renderer(device: device)
    metalView.delegate = renderer

    commandQueue = device.makeCommandQueue()
  }
}


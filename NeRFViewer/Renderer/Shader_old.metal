//
//  Shader.metal
//  BrightnessShader
//
//  Created by Venkat Rao on 3/9/22.
//

#include <metal_stdlib>
using namespace metal;


struct Constants {
  float animateBy;
};

struct VertexIn {
  float4 position [[ attribute(0) ]];
  float4 color [[ attribute(1) ]];
  float2 textureCoordinates [[ attribute(2) ]];
};

struct VertexOut {
  float4 position [[ position ]];
  float4 color;
  float2 textureCoordinates;
};

vertex VertexOut vertex_shader(const VertexIn vertexIn [[stage_in]]) {
  VertexOut vertexOut;
  vertexOut.position = vertexIn.position;
  vertexOut.color = vertexIn.color;
  vertexOut.textureCoordinates = vertexIn.textureCoordinates;

  return vertexOut;
}

fragment half4 fragment_shader(VertexOut vertexIn [[ stage_in ]]) {
  return half4(vertexIn.color);
}

fragment half4 texture_fragment(VertexOut vertexIn [[ stage_in ]],
                                texture2d<float> texture [[ texture(0) ]]) {
  constexpr sampler defaultSampler;
  float4 color = texture.sample(defaultSampler, vertexIn.textureCoordinates);
  return half4(color.r, color.g, color.b, 1);
}

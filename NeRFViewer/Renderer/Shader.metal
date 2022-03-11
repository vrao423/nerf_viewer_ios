//
//  Shader.metal
//  BrightnessShader
//
//  Created by Venkat Rao on 3/9/22.
//

#include <metal_stdlib>
using namespace metal;

struct FragmentConstants {
  float animateBy;
  float bar;
  float4 foo;
  
  // Stuff from the viewer shader. (Remeber to update the others)
  int displayMode;
  int ndc;
  
  float3 minPosition;
  float3 gridSize;
  float3 atlasSize;
  float voxelSize;
  float blockSize;
  float3x3 worldspace_R_opengl;
  float nearPlane;
  
  float ndc_h;
  float ndc_w;
  float ndc_f;
};

struct NodeBuffer {
  float4x4 modelTransform;
  float4x4 modelViewProjectionTransform;
  float4x4 modelViewTransform;
  float4x4 normalTransform;
  float2x3 boundingBox;
};

struct VertexConstants {
  float4x4 world_T_clip;
};

struct VertexIn {
  float3 position [[ attribute(0) ]];
  float4 color [[ attribute(1) ]];
};

struct VertexOut {
  float4 position [[ position ]];
  float4 color;
  
  // Stuff from the viewer shader.
  float3 vOrigin;
  float3 vDirection;
};

vertex VertexOut vertex_shader(const VertexIn vertexIn [[stage_in]],
                               constant FragmentConstants &fragmentConstants [[buffer(1)]],
                               constant VertexConstants &vertexConstants [[buffer(2)]]) {
  VertexOut vertexOut;
  vertexOut.position = float4(vertexIn.position,1);
  vertexOut.position.x += fragmentConstants.animateBy;
  vertexOut.color = vertexIn.color;
  
  // The actual viewer stuff:
  //float4 positionClip =

  return vertexOut;
}

fragment half4 fragment_shader(VertexOut vertexOut [[stage_in]],
                               constant FragmentConstants &fragmentConstants [[buffer(1)]]) {
  return half4(fragmentConstants.foo);
}

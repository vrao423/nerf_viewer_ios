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

struct VertexIn {
  float4 position [[ attribute(0) ]];
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
                               constant FragmentConstants &constants [[buffer(1)]]) {
    VertexOut vertexOut;
    vertexOut.position = vertexIn.position;
    vertexOut.position.x += constants.animateBy;
    vertexOut.color = vertexIn.color;

    return vertexOut;
}

fragment half4 fragment_shader(VertexOut vertexIn [[stage_in]]) {
    return half4(vertexIn.color);
}

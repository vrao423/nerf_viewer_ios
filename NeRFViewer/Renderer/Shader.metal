// NeRFViewer Shader.

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

struct FragmentConstants {
  // Stuff from the viewer shader.
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
  float4x4 inverseModelViewProjectionTransform;
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

// Vertex Shader main
vertex VertexOut vertex_shader(const VertexIn vertexIn [[stage_in]],
                               constant NodeBuffer& scn_node [[buffer(1)]],
                               constant VertexConstants& vertexConstants [[buffer(2)]]) {
  
  float4x4 world_T_camera = scn_node.modelTransform;
  float4x4 camera_T_clip = scn_node.inverseModelViewProjectionTransform;
  float4x4 world_T_clip = world_T_camera * camera_T_clip;
  
  VertexOut vertexOut;
  // positionClip within -1 to 1. modelViewProjectionTransform is from the actual camera.
  float4 positionClip = scn_node.modelViewProjectionTransform * float4(vertexIn.position.x, vertexIn.position.y, 0.0, 1.0);
  
  positionClip /= positionClip.w;
  float4 nearPoint = world_T_clip * float4(positionClip.x, positionClip.y, -1.0, 1.0);
  float4 farPoint = world_T_clip * float4(positionClip.x, positionClip.y, 1.0, 1.0);

  vertexOut.position = positionClip;
  vertexOut.vOrigin = nearPoint.xyz / nearPoint.w;
  vertexOut.vDirection = normalize(farPoint.xyz / farPoint.w - vertexOut.vOrigin);
  
  return vertexOut;
}

// Fragment Shader Helper Code.
float3 convertOriginToNDC(float3 origin, float3 direction, float ndc_f, float ndc_w, float ndc_h) {
  // We store the NDC scenes flipped, so flip back.
  origin.z *= -1.0;
  direction.z *= -1.0;

  const float near = 1.0;
  float t = -(near + origin.z) / direction.z;
  origin = origin * t + direction;

  // Hardcoded, worked out using approximate iPhone FOV of 67.3 degrees
  // and an image width of 1006 px.
  float focal = ndc_f;
  float W = ndc_w;
  float H = ndc_h;
  float o0 = 1.0 / (W / (2.0 * focal)) * origin.x / origin.z;
  float o1 = -1.0 / (H / (2.0 * focal)) * origin.y / origin.z;
  float o2 = 1.0 + 2.0 * near / origin.z;

  origin = float3(o0, o1, o2);
  origin.z *= -1.0;
  return origin;
}

float3 convertDirectionToNDC(float3 origin, float3 direction,float ndc_f, float ndc_w, float ndc_h) {
   // We store the NDC scenes flipped, so flip back.
   origin.z *= -1.0;
   direction.z *= -1.0;

   const float near = 1.0;
   float t = -(near + origin.z) / direction.z;
   origin = origin * t + direction;

   // Hardcoded, worked out using approximate iPhone FOV of 67.3 degrees
   // and an image width of 1006 px.
   float focal = ndc_f;
   float W = ndc_w;
   float H = ndc_h;

   float d0 = 1.0 / (W / (2.0 * focal)) *
     (direction.x / direction.z - origin.x / origin.z);
   float d1 = -1.0 / (H / (2.0 * focal)) *
     (direction.y / direction.z - origin.y / origin.z);
   float d2 = -2.0 * near / origin.z;

   direction = normalize(float3(d0, d1, d2));
   direction.z *= -1.0;
   return direction;
 }

// Compute the atlas block index for a point in the scene using pancake
// 3D atlas packing.
float3 pancakeBlockIndex(float3 posGrid, float blockSize, uint3 iBlockGridBlocks, float3 atlasSize) {
  int3 iBlockIndex = int3(floor(posGrid / blockSize));
  int3 iAtlasBlocks = int3(atlasSize) / int3(blockSize + 2.0);
  int linearIndex = iBlockIndex.x + iBlockGridBlocks.x *
    (iBlockIndex.z + iBlockGridBlocks.z * iBlockIndex.y);

  float3 atlasBlockIndex = float3(
    float(linearIndex % iAtlasBlocks.x),
    float((linearIndex / iAtlasBlocks.x) % iAtlasBlocks.y),
    float(linearIndex / (iAtlasBlocks.x * iAtlasBlocks.y)));

  // If we exceed the size of the atlas, indicate an empty voxel block.
  if (atlasBlockIndex.z >= float(iAtlasBlocks.z)) {
    atlasBlockIndex = float3(-1.0, -1.0, -1.0);
  }

  return atlasBlockIndex;
}

float2 rayAabbIntersection(uint3 aabbMin, uint3 aabbMax,float3 origin,float3 invDirection) {
  float3 t1 = (float3(aabbMin) - origin) * invDirection;
  float3 t2 = (float3(aabbMax) - origin) * invDirection;
  float3 tMin = min(t1, t2);
  float3 tMax = max(t1, t2);
  return float2(max(tMin.x, max(tMin.y, tMin.z)),
              min(tMax.x, min(tMax.y, tMax.z)));
}


// Fragment Shader main.
fragment float4 fragment_shader(VertexOut vertexOut [[stage_in]],
                               constant NodeBuffer& scn_node [[buffer(1)]],
                               constant FragmentConstants &fragmentConstants [[buffer(2)]],
                               texture3d<uint, access::sample> mapAlpha [[texture(0)]],
                               texture3d<uint, access::sample> mapColor [[texture(1)]],
                               texture3d<uint, access::sample> mapFeatures [[texture(2)]],
                               texture3d<uint, access::sample> mapIndex [[texture(3)]],
                               texture2d<uint, access::sample> weightsZero [[texture(4)]],
                               texture2d<uint, access::sample> weightsOne [[texture(5)]],
                               texture2d<uint, access::sample> weightsTwo [[texture(6)]]) {
  
  //return float4(1.0,0.0,1.0,1.0);

  // See the DisplayMode enum at the top of this file.
  // Runs the full model with view dependence.
  const int DISPLAY_NORMAL = 0;
  // Disables the view-dependence network.
  const int DISPLAY_DIFFUSE = 1;
  // Only shows the latent features.
  const int DISPLAY_FEATURES = 2;
  // Only shows the view dependent component.
  const int DISPLAY_VIEW_DEPENDENT = 3;
  // Only shows the coarse block grid.
  const int DISPLAY_COARSE_GRID = 4;
  // Only shows the 3D texture atlas.
  const int DISPLAY_3D_ATLAS = 5;


  // Set up the ray parameters in world space..
  float nearWorld = fragmentConstants.nearPlane;
  float3 originWorld = vertexOut.vOrigin;
  float3 directionWorld = normalize(vertexOut.vDirection);
  if (fragmentConstants.ndc != 0) {
    nearWorld = 0.0;
    originWorld = convertOriginToNDC(vertexOut.vOrigin, normalize(vertexOut.vDirection), fragmentConstants.ndc_f, fragmentConstants.ndc_w, fragmentConstants.ndc_h);
    directionWorld = convertDirectionToNDC(vertexOut.vOrigin, normalize(vertexOut.vDirection),fragmentConstants.ndc_f, fragmentConstants.ndc_w, fragmentConstants.ndc_h);
  }

  // Now transform them to the voxel grid coordinate system.
  float3 originGrid = (originWorld - fragmentConstants.minPosition) / fragmentConstants.voxelSize;
  float3 directionGrid = directionWorld;
  float3 invDirectionGrid = 1.0 / directionGrid;

  uint3 iGridSize = uint3(round(fragmentConstants.gridSize));
  uint iBlockSize = uint(round(fragmentConstants.blockSize));
  uint3 iBlockGridBlocks = (iGridSize + iBlockSize - 1) / iBlockSize;
  uint3 iBlockGridSize = iBlockGridBlocks * iBlockSize;
  uint3 blockGridSize = uint3(iBlockGridSize);
  float2 tMinMax = rayAabbIntersection(
     uint3(0.0, 0.0, 0.0), uint3(fragmentConstants.gridSize), originGrid, invDirectionGrid);

  // Skip any rays that miss the scene bounding box.
  if (tMinMax.x > tMinMax.y) {
      return float4(1.0, 1.0, 0.0, 1.0);
  }

  float t = max(nearWorld / fragmentConstants.voxelSize, tMinMax.x) + 0.5;
  float3 posGrid = originGrid + directionGrid * t;

  uint3 blockNum = uint3(floor(posGrid / fragmentConstants.blockSize));

  uint3 blockMin = blockNum * int(fragmentConstants.blockSize);
  uint3 blockMax = blockMin + int(fragmentConstants.blockSize);
  float2 tBlockMinMax = rayAabbIntersection(
            blockMin, blockMax, originGrid, invDirectionGrid);
  uint3 atlasBlockIndex;

  // NOT SURE IF THIS IS CORRECT...
  constexpr sampler textureSampler (mag_filter::linear,
                                    min_filter::nearest);

  if (fragmentConstants.displayMode == DISPLAY_3D_ATLAS) {
    atlasBlockIndex = uint3(pancakeBlockIndex(posGrid, fragmentConstants.blockSize, iBlockGridBlocks, fragmentConstants.atlasSize));
  } else {
    // Sample the texture to obtain a color
    uint3 sampleIndex = (blockMin + blockMax) / (2 * blockGridSize);
    atlasBlockIndex = 255 * mapIndex.sample(textureSampler, float3(sampleIndex)).xyz;
  }

    float visibility = 1.0;
    float3 color = float3(0.0, 0.0, 0.0);
    float4 features = float4(0.0, 0.0, 0.0, 0.0);
    int step = 0;
    int maxStep = int(ceil(length(fragmentConstants.gridSize)));

    while (step < maxStep && t < tMinMax.y && visibility > 1.0 / 255.0) {
      // Skip empty macroblocks.
      if (atlasBlockIndex.x > 254.0) {
        t = 0.5 + tBlockMinMax.y;
      }
      else { // Otherwise step through them and fetch RGBA and Features.
        float3 posAtlas = clamp(posGrid - float3(blockMin), 0.0, fragmentConstants.blockSize);
        posAtlas += float3(atlasBlockIndex) * (fragmentConstants.blockSize + 2.0);
        posAtlas += 1.0; // Account for the one voxel padding in the atlas.

        if (fragmentConstants.displayMode == DISPLAY_COARSE_GRID) {
          color = float3(atlasBlockIndex) * (fragmentConstants.blockSize + 2.0) / fragmentConstants.atlasSize;
          features.rgb = float3(atlasBlockIndex) * (fragmentConstants.blockSize + 2.0) / fragmentConstants.atlasSize;
          features.a = 1.0;
          visibility = 0.0;
          continue;
        }

        // Do a conservative fetch for alpha!=0 at a lower resolution,
        // and skip any voxels which are empty. First, this saves bandwidth
        // since we only fetch one byte instead of 8 (trilinear) and most
        // fetches hit cache due to low res. Second, this is conservative,
        // and accounts for any possible alpha mass that the high resolution
        // trilinear would find.
        const int skipMipLevel = 2;
        const float miniBlockSize = float(1 << skipMipLevel);

        // Only fetch one byte at first, to conserve memory bandwidth in
        // empty space.
        // why uint??, not sure how to use skipMipLevel in here.
        uint3 coord = uint3(posAtlas / miniBlockSize);
        float atlasAlpha = mapAlpha.read(coord).x;

        if (atlasAlpha > 0.0) {
          // OK, we hit something, do a proper trilinear fetch at high res.
          float3 atlasUvw = posAtlas / fragmentConstants.atlasSize;

          // Note: Not sure sample == textureLod(,,0).
          atlasAlpha = mapAlpha.sample(textureSampler, atlasUvw).x;

          // Only worth fetching the content if high res alpha is non-zero.
          if (atlasAlpha > 0.5 / 255.0) {
            float4 atlasRgba = float4(0.0, 0.0, 0.0, atlasAlpha);
            atlasRgba.rgb = float3(mapColor.sample(textureSampler, atlasUvw).rgb);
            if (fragmentConstants.displayMode != DISPLAY_DIFFUSE) {
              float4 atlasFeatures = float4(mapFeatures.sample(textureSampler, atlasUvw));
              features += visibility * atlasFeatures;
            }
            color += visibility * atlasRgba.rgb;
            visibility *= 1.0 - atlasRgba.a;
          }
        }
        t += 1.0;
      }

      posGrid = originGrid + directionGrid * t;
      if (t > tBlockMinMax.y) {
       blockMin = uint3(floor(posGrid / fragmentConstants.blockSize) * fragmentConstants.blockSize);
       blockMax = blockMin + uint3(fragmentConstants.blockSize);
       tBlockMinMax = rayAabbIntersection(
             blockMin, blockMax, originGrid, invDirectionGrid);

       if (fragmentConstants.displayMode == DISPLAY_3D_ATLAS) {
         atlasBlockIndex = uint3(pancakeBlockIndex(
           posGrid, fragmentConstants.blockSize, iBlockGridBlocks, fragmentConstants.atlasSize));
       } else {
         uint3 sampleIndex = (blockMin + blockMax) / (2 * blockGridSize);
         atlasBlockIndex = 255 * mapIndex.sample(textureSampler, float3(sampleIndex)).xyz;
       }
      }
      step++;
    }

    if (fragmentConstants.displayMode == DISPLAY_VIEW_DEPENDENT) {
      color = float3(0.0, 0.0, 0.0) * visibility;
    } else if (fragmentConstants.displayMode == DISPLAY_FEATURES) {
      color = features.rgb;
    }

    // Compute the final color, to save compute only compute view-depdence
   // for rays that intersected something in the scene.
   color = float3(1.0, 1.0, 1.0) * visibility + color;

  return float4(color, 1.0);
}

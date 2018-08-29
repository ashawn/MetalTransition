//
//  transition.metal
//  MetalTransition
//
//  Created by ashawn on 17/08/2018.
//  Copyright © 2018 ashawn. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

typedef struct
{
    float4 position [[position]];
    float2 texCoords;
}VertexOut;

typedef struct {
    float progress;
} SharedUniform;

vertex VertexOut pass_vertex(const device float4* vertexArray [[buffer(0)]],
                                 const device float2* texCoordsArray [[buffer(1)]],
                                              unsigned int vid  [[vertex_id]]){
    
    VertexOut verOut;
    verOut.position = vertexArray[vid];
    verOut.texCoords = texCoordsArray[vid];
    return verOut;
    
}

fragment float4 fade_fragment(
                             VertexOut input [[stage_in]],
                             constant SharedUniform &sharedUniform [[ buffer(2) ]],
                             texture2d<float> fromImage [[texture(0)]],
                             texture2d<float> toImage [[texture(1)]]
                             )
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    
    return mix(fromImage.sample(textureSampler, input.texCoords),toImage.sample(textureSampler, input.texCoords),sharedUniform.progress);
}

fragment float4 ripple_fragment(
                                VertexOut input [[stage_in]],
                                constant SharedUniform &sharedUniform [[ buffer(2) ]],
                                texture2d<float> fromImage [[ texture(0) ]],
                                texture2d<float> toImage [[ texture(1) ]]
                                )
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    
    float2 dir = input.texCoords - float2(.5);
    float dist = length(dir);
    float2 offset = dir * (sin(sharedUniform.progress * dist * 100 - sharedUniform.progress * 50) + .5) / 30.;
    return mix(fromImage.sample(textureSampler, input.texCoords + offset),toImage.sample(textureSampler, input.texCoords),smoothstep(0.0, 1.0, sharedUniform.progress));
}

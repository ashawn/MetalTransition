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

vertex VertexOut vertex_function(const device float4* vertexArray [[buffer(0)]],
                                 const device float2* texCoordsArray [[buffer(1)]],
                                              unsigned int vid  [[vertex_id]]){
    
    VertexOut verOut;
    verOut.position = vertexArray[vid];
    verOut.texCoords = texCoordsArray[vid];
    return verOut;
    
}

fragment float4 fragment_function(
                                 VertexOut input [[stage_in]],
                                 texture2d<float> fromImage [[texture(0)]],
                                 texture2d<float> toImage [[texture(1)]]
                                 )
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器
    
    float4 color = float4(0,0,1,1);//fromImage.sample(textureSampler, input.texCoords);
    return color;
    
}

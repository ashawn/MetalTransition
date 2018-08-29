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

//common vertex shader
vertex VertexOut pass_vertex(const device float4* vertexArray [[buffer(0)]],
                                 const device float2* texCoordsArray [[buffer(1)]],
                                              unsigned int vid  [[vertex_id]]){
    
    VertexOut verOut;
    verOut.position = vertexArray[vid];
    verOut.texCoords = texCoordsArray[vid];
    return verOut;
    
}

//fade fragment shader
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

//fold fragment shader
fragment float4 fold_fragment(
                              VertexOut input [[stage_in]],
                              constant SharedUniform &sharedUniform [[ buffer(2) ]],
                              texture2d<float> fromImage [[texture(0)]],
                              texture2d<float> toImage [[texture(1)]]
                              )
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    
    float4 fromTextureColor = fromImage.sample(textureSampler, (input.texCoords - float2(sharedUniform.progress, 0.0)) / float2(1.0 - sharedUniform.progress, 1.0));
    float4 toTextureColor = toImage.sample(textureSampler, input.texCoords / float2(sharedUniform.progress, 1.0));
    
    return mix(fromTextureColor,toTextureColor,step(input.texCoords.x, sharedUniform.progress));
}

//wave fragment shader
float compute(float2 p, float progress, float2 center) {
    float amplitude = 1.0;
    float waves = 30.0;
    float PI = 3.1415926;
    float2 o = p * sin(progress * amplitude) - center;
    float2 h = float2(1.0, 0.0);
    float theta = acos(dot(o, h)) * waves;
    return (exp(cos(theta)) - 2.0 * cos(4.0 * theta) + pow(sin((2.0 * theta - PI) / 24.0), 5.0)) / 10.0;
}

fragment float4 wave_fragment(
                              VertexOut input [[stage_in]],
                              constant SharedUniform &sharedUniform [[ buffer(2) ]],
                              texture2d<float> fromImage [[texture(0)]],
                              texture2d<float> toImage [[texture(1)]]
                              )
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    
    float colorSeparation = 0.5;
    float inv = 1.0 - sharedUniform.progress;
    float2 p = input.texCoords.xy / float2(1.0).xy;
    float disp = compute(p, sharedUniform.progress, float2(0.5, 0.5));
    float4 fromTextureColor = float4(fromImage.sample(textureSampler, p + sharedUniform.progress * disp * (1.0 - colorSeparation)).x,
                                     fromImage.sample(textureSampler, p + sharedUniform.progress * disp).y,
                                     fromImage.sample(textureSampler, p + sharedUniform.progress * disp * (1.0 - colorSeparation)).z,
                                     1.0);
    float4 toTextureColor = toImage.sample(textureSampler, p + inv * disp);
    
    return toTextureColor * sharedUniform.progress + fromTextureColor * inv;
}

//crosswarp fragment shader
fragment float4 crosswarp_fragment(
                              VertexOut input [[stage_in]],
                              constant SharedUniform &sharedUniform [[ buffer(2) ]],
                              texture2d<float> fromImage [[texture(0)]],
                              texture2d<float> toImage [[texture(1)]]
                              )
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    float process = smoothstep(0.0, 1.0, (sharedUniform.progress * 2.0 + input.texCoords.x - 1.0));
    float4 fromTextureColor = fromImage.sample(textureSampler, (input.texCoords - 0.5) * (1.0 - process) + 0.5);
    float4 toTextureColor = toImage.sample(textureSampler, (input.texCoords - 0.5) * process + 0.5);
    
    return mix(fromTextureColor,toTextureColor,step(input.texCoords.x, sharedUniform.progress));
}

//radial fragment shader
fragment float4 radial_fragment(
                                   VertexOut input [[stage_in]],
                                   constant SharedUniform &sharedUniform [[ buffer(2) ]],
                                   texture2d<float> fromImage [[texture(0)]],
                                   texture2d<float> toImage [[texture(1)]]
                                   )
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    float smoothness = 1.0;
    float PI = 3.1415926;
    float2 rp = input.texCoords * 2.0 - 1.0;
    float4 fromTextureColor = fromImage.sample(textureSampler, input.texCoords);
    float4 toTextureColor = toImage.sample(textureSampler, input.texCoords);
    
    return mix(toTextureColor, fromTextureColor, smoothstep(0., smoothness, atan2(rp.y, rp.x) - (sharedUniform.progress - 0.5) * PI * 2.5));
}

//pin wheel fragment shader
fragment float4 pinwheel_fragment(
                                VertexOut input [[stage_in]],
                                constant SharedUniform &sharedUniform [[ buffer(2) ]],
                                texture2d<float> fromImage [[texture(0)]],
                                texture2d<float> toImage [[texture(1)]]
                                )
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    float speed = 2.0;
    float2 p = input.texCoords.xy / float2(1.0).xy;
    float circPos = atan2(p.y - 0.5, p.x - 0.5) + sharedUniform.progress * speed;
    float modPos = fmod(circPos, 3.1415926 / 4.0);
    float signeda = sign(sharedUniform.progress - modPos);
    
    float4 fromTextureColor = fromImage.sample(textureSampler, p);
    float4 toTextureColor = toImage.sample(textureSampler, p);
    
    return mix(toTextureColor, fromTextureColor, step(signeda, 0.5));
}

//ripple fragment shader
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

//horizontal fragment shader
float2 N22(float2 p)
{
    float3 a = fract(float3(p,p.x) * float3(123.34,234.34,345.65));
    a += dot(a,a+34.45);
    return fract(float2(a.x*a.y,a.y*a.z));
}
float fit(float val,float inmin,float inmax,float outmin,float outmax)
{
    return clamp((outmin + (val - inmin) * (outmax - outmin) / (inmax - inmin)),outmin,outmax);
}
float4x4 rotationMatrix(float3 axis, float a)
{
    axis = normalize(axis);
    float s = sin(a);
    float c = cos(a);
    float oc = 1.0 - c;
    float4x4 matrix;
    matrix[0] = float4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0);
    matrix[1] = float4(oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0);
    matrix[2] = float4(oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0);
    matrix[3] = float4(0.0,                                0.0,                                0.0,                                1.0);
    return matrix;
}

fragment float4 horizontal_fragment(
                                    VertexOut input [[stage_in]],
                                    constant SharedUniform &sharedUniform [[ buffer(2) ]],
                                    texture2d<float> fromImage [[ texture(0) ]],
                                    texture2d<float> toImage [[ texture(1) ]]
                                    )
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器
    
    float2 uv = input.texCoords;
    float t = sharedUniform.progress * 1.5;
    float div = 350.0;//div;
    //float diagonal = atan2(1.0,1.0);
    float2 dir = float2(1.0,0.0);
    float3 axis = float3(0.0,0.0,1.0);
    
    float angleR = 1.57;//radians(90.0);
    //angleR = diagonal;
    float4x4 rot = rotationMatrix(axis,angleR);
    
    dir = (rot*float4(dir,0.0,1.0)).xy;
    float2 tempuv = (rot*float4((uv-0.5)*float2(1.0,1.0),0.0,1.0)).xy;
    tempuv = fract(tempuv);
    float2 checkeruv = floor(tempuv*float2(div,1.0));
    float offset = N22(checkeruv*19.5).x;
    offset = fit(offset,0.,1.,0.25,1.0);
    float ani = pow(smoothstep(0.,1.5,t),2.0);
    offset = offset*ani*10.0;
    float max = 1.0;
    
    offset = clamp(offset,0.,max);
    dir *= offset;
    uv -= dir.yx;
    uv = fract(uv);
    return mix(fromImage.sample(textureSampler, uv),toImage.sample(textureSampler, uv),smoothstep(0.2, 1.0, sharedUniform.progress));
}

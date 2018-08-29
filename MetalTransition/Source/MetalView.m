//
//  MetalView.m
//  MetalTransition
//
//  Created by ashawn on 17/08/2018.
//  Copyright © 2018 ashawn. All rights reserved.
//

#import "MetalView.h"
#import "MetalTransition.h"

typedef struct {
    float progress;
} SharedUniform;

@interface MetalProgressLayer : CALayer

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) void(^progressUpdating)(CGFloat progress);

@end

@implementation MetalProgressLayer

@dynamic progress;

+ (BOOL)needsDisplayForKey:(NSString *)key{
    if ([key isEqualToString:@"progress"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)display{
    if (_progressUpdating) {
        _progressUpdating([[self presentationLayer] progress]);
    }
}

@end

@interface MetalView () <MTKViewDelegate, CAAnimationDelegate>

// Long-lived Metal objects
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLLibrary> defaultLibrary;
// Resources
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> texCoordsBuffer;
@property (nonatomic, strong) id<MTLBuffer> sharedUniformBuffer;
@property (nonatomic, strong) id<MTLTexture> fromTex;
@property (nonatomic, strong) id<MTLTexture> toTex;
@property (nonatomic, assign) vector_uint2 viewportSize;

@property (nonatomic, weak) MetalProgressLayer *progressLayer;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) void(^completion)(BOOL finish);
@property (nonatomic, assign) CGFloat lastProgress;

@end

@implementation MetalView

- (instancetype)initWithFrame:(CGRect)frame
                    fromImage:(UIImage *)fromImage
                      toImage:(UIImage *)toImage
                       shader:(MetalTransitionShaderType)shader{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    MetalProgressLayer *layer = [MetalProgressLayer new];
    self.progressLayer = layer;
    self.progressLayer.frame = CGRectMake(0, 0, 100, 100);
    __weak typeof(self)weakSelf = self;
    self.progressLayer.progressUpdating = ^(CGFloat progress){
        weakSelf.progress = progress;
        [weakSelf setNeedsDisplay];
    };
    [self.layer insertSublayer:self.progressLayer atIndex:0];
    
    [self setupPipeline:shader];
    
    self.fromTex = [self setupTexture:fromImage];
    self.toTex = [self setupTexture:toImage];
    [self setupVertex];
    
    return self;
}

- (void)setupPipeline:(MetalTransitionShaderType)shader {
    
    self.delegate = self;
    
    self.device = MTLCreateSystemDefaultDevice();
    self.viewportSize = (vector_uint2){self.drawableSize.width, self.drawableSize.height};
    self.defaultLibrary = [self.device newDefaultLibrary];
    
    // Fetch the vertex and fragment functions from the library
    id<MTLFunction> vertexProgram = [self.defaultLibrary newFunctionWithName:@"pass_vertex"];
    id<MTLFunction> fragmentProgram;
    switch (shader) {
        case MetalTransitionShaderTypeFade:
            fragmentProgram = [self.defaultLibrary newFunctionWithName:@"fade_fragment"];
            break;
        case MetalTransitionShaderTypeFold:
            fragmentProgram = [self.defaultLibrary newFunctionWithName:@"fold_fragment"];
            break;
        case MetalTransitionShaderTypeRipple:
            fragmentProgram = [self.defaultLibrary newFunctionWithName:@"ripple_fragment"];
            break;
        case MetalTransitionShaderTypeHorizontal:
            fragmentProgram = [self.defaultLibrary newFunctionWithName:@"horizontal_fragment"];
            break;
        case MetalTransitionShaderTypeWave:
            fragmentProgram = [self.defaultLibrary newFunctionWithName:@"wave_fragment"];
            break;
        case MetalTransitionShaderTypeCrosswarp:
            fragmentProgram = [self.defaultLibrary newFunctionWithName:@"crosswarp_fragment"];
            break;
        case MetalTransitionShaderTypeRadial:
            fragmentProgram = [self.defaultLibrary newFunctionWithName:@"radial_fragment"];
            break;
        case MetalTransitionShaderTypePinwheel:
            fragmentProgram = [self.defaultLibrary newFunctionWithName:@"pinwheel_fragment"];
            break;
        default:
            break;
    }
    
    // Build a render pipeline descriptor with the desired functions
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    [pipelineStateDescriptor setVertexFunction:vertexProgram];
    [pipelineStateDescriptor setFragmentFunction:fragmentProgram];
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    // Compile the render pipeline
    NSError* error = NULL;
    self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!self.pipelineState) {
        NSLog(@"Failed to created pipeline state, error %@", error);
    }
    else{
        self.commandQueue = [self.device newCommandQueue];
    }
}

- (id<MTLTexture>)setupTexture:(UIImage*)image {
    
    MTKTextureLoader *loader = [[MTKTextureLoader alloc]initWithDevice:self.device];
    NSError* err;
    id<MTLTexture> texture = [loader newTextureWithCGImage:image.CGImage options:nil error:&err];
    
    return texture;
}

- (void)setupVertex {
    static float vertexs[] = {
        -1.0,  1.0, 0.0, 1.0,
        -1.0, -1.0, 0.0, 1.0,
        1.0,  1.0, 0.0, 1.0,
        1.0, -1.0, 0.0, 1.0,
    };
    
    static float texCoords[] = {
        0.0,  0.0,
        0.0, 1.0,
        1.0,  0.0,
        1.0, 1.0,
    };
    
    self.vertexBuffer = [self.device newBufferWithBytes:vertexs
                                                 length:sizeof(vertexs)
                                                options:MTLResourceStorageModeShared];
    self.texCoordsBuffer = [self.device newBufferWithBytes:texCoords
                                                    length:sizeof(texCoords)
                                                   options:MTLResourceStorageModeShared];
}

- (void)updateSharedUniform {
    SharedUniform uniform;
    uniform.progress = self.progress;
    self.sharedUniformBuffer = [self.device newBufferWithBytes:&uniform
                                                        length:sizeof(uniform)
                                                       options:MTLResourceStorageModeShared];
}

- (void)metalViewDoAnimation:(NSTimeInterval)duration completion:(void (^ __nullable)(BOOL finished))completion{
    self.completion = completion;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
    animation.fromValue = @0;
    animation.toValue = @1;
    
    animation.duration = duration;
    animation.delegate = self;
    [self.progressLayer addAnimation:animation forKey:@"metalProgressAnimation"];
}

#pragma mark - delegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    self.viewportSize = (vector_uint2){size.width, size.height};
}

- (void)drawInMTKView:(MTKView *)view {
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if(renderPassDescriptor != nil)
    {
        [self updateSharedUniform];
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0f);
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, self.viewportSize.x, self.viewportSize.y, -1.0, 1.0 }];
        [renderEncoder setRenderPipelineState:self.pipelineState];
        
        [renderEncoder setVertexBuffer:self.vertexBuffer
                                offset:0
                               atIndex:0];
        [renderEncoder setVertexBuffer:self.texCoordsBuffer
                                offset:0
                               atIndex:1];
        [renderEncoder setFragmentBuffer:self.sharedUniformBuffer
                                  offset:0
                                 atIndex:2];
        
        [renderEncoder setFragmentTexture:self.fromTex
                                  atIndex:0];
        [renderEncoder setFragmentTexture:self.toTex
                                  atIndex:1];
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip
                          vertexStart:0
                          vertexCount:4];
        
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
}

#pragma mark - <CAAnimationDelegate>

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (_completion) {
        _completion(flag);
    }
    _completion = nil;
}

@end

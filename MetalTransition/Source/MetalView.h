//
//  MetalView.h
//  MetalTransition
//
//  Created by ashawn on 17/08/2018.
//  Copyright © 2018 ashawn. All rights reserved.
//

#import "MetalTransition.h"
@import MetalKit;

@interface MetalView : MTKView

- (instancetype)initWithFrame:(CGRect)frame
                    fromImage:(UIImage *)fromImage
                      toImage:(UIImage *)toImage
                       shader:(MetalTransitionShaderType)shader;
- (void)metalViewDoAnimation:(NSTimeInterval)duration completion:(void (^ __nullable)(BOOL finished))completion;

@end

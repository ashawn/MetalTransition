//
//  MetalTransition.h
//  MetalTransition
//
//  Created by ashawn on 11/08/2018.
//  Copyright © 2018 ashawn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MetalTransitionType) {
    MetalTransitionTypePresent = 0,
    MetalTransitionTypeDismiss,
    MetalTransitionTypePush,
    MetalTransitionTypePop,
};

typedef NS_ENUM(NSUInteger, MetalTransitionShaderType) {
    MetalTransitionShaderTypeFade = 0,
    MetalTransitionShaderTypeFold,
    MetalTransitionShaderTypeRipple,
    MetalTransitionShaderTypeHorizontal,
};

@interface MetalTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) MetalTransitionType type;
@property (nonatomic, assign) MetalTransitionShaderType shader;

+ (instancetype)transitionWithTransitionType:(MetalTransitionType)type shader:(MetalTransitionShaderType)shader;

@end

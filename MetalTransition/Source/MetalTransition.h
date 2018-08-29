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

@interface MetalTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) MetalTransitionType type;

+ (instancetype)transitionWithTransitionType:(MetalTransitionType)type;
- (instancetype)initWithTransitionType:(MetalTransitionType)type;

@end
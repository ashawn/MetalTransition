//
//  MetalTransition.m
//  MetalTransition
//
//  Created by ashawn on 11/08/2018.
//  Copyright © 2018 ashawn. All rights reserved.
//

#import "MetalTransition.h"
#import "MetalView.h"

@implementation MetalTransition

+ (instancetype)transitionWithTransitionType:(MetalTransitionType)type shader:(MetalTransitionShaderType)shader{
    return [[self alloc] initWithTransitionType:type shader:shader];
}

- (instancetype)initWithTransitionType:(MetalTransitionType)type shader:(MetalTransitionShaderType)shader{
    self = [super init];
    if (self) {
        _type = type;
        _shader = shader;
    }
    return self;
}

- (UIImage *)imageFromsnapshotView:(UIView *)view{
    CALayer *layer = view.layer;
    UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    switch (_type) {
        case MetalTransitionTypePresent:
            [self presentAnimation:transitionContext];
            break;
            
        case MetalTransitionTypeDismiss:
            [self dismissAnimation:transitionContext];
            break;
        case MetalTransitionTypePush:
            [self pushAnimation:transitionContext];
            break;
            
        case MetalTransitionTypePop:
            [self popAnimation:transitionContext];
            break;
        default:
            break;
    }
    
}

- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    MetalView *metalView = [[MetalView alloc] initWithFrame:containerView.bounds fromImage:[self imageFromsnapshotView:fromVC.view] toImage:[self imageFromsnapshotView:toVC.view] shader:self.shader];
    [containerView addSubview:metalView];
    
    [metalView metalViewDoAnimation:[self transitionDuration:transitionContext] completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [containerView addSubview:fromVC.view];
        } else {
            [containerView addSubview:toVC.view];
        }
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [metalView removeFromSuperview];
    }];
}

- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    MetalView *metalView = [[MetalView alloc] initWithFrame:containerView.bounds fromImage:[self imageFromsnapshotView:fromVC.view] toImage:[self imageFromsnapshotView:toVC.view] shader:self.shader];
    [containerView addSubview:metalView];
    
    [metalView metalViewDoAnimation:[self transitionDuration:transitionContext] completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [containerView addSubview:fromVC.view];
        } else {
            [containerView addSubview:toVC.view];
        }
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [metalView removeFromSuperview];
    }];
}

- (void)pushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    MetalView *metalView = [[MetalView alloc] initWithFrame:containerView.bounds fromImage:[self imageFromsnapshotView:fromVC.view] toImage:[self imageFromsnapshotView:toVC.view] shader:self.shader];
    [containerView addSubview:metalView];
    
    [metalView metalViewDoAnimation:[self transitionDuration:transitionContext] completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [containerView addSubview:fromVC.view];
        } else {
            [containerView addSubview:toVC.view];
        }
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [metalView removeFromSuperview];
    }];
}

- (void)popAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    MetalView *metalView = [[MetalView alloc] initWithFrame:containerView.bounds fromImage:[self imageFromsnapshotView:fromVC.view] toImage:[self imageFromsnapshotView:toVC.view] shader:self.shader];
    [containerView addSubview:metalView];
    
    [metalView metalViewDoAnimation:[self transitionDuration:transitionContext] completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [containerView addSubview:fromVC.view];
        } else {
            [containerView addSubview:toVC.view];
        }
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [metalView removeFromSuperview];
    }];
}

@end

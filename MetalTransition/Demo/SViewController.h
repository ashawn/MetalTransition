//
//  SViewController.h
//  MetalTransition
//
//  Created by ashawn on 11/08/2018.
//  Copyright © 2018 ashawn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetalTransition.h"

@interface SViewController : UIViewController

- (instancetype)initWithShader :(MetalTransitionShaderType)shader;

@end

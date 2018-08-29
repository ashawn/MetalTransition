//
//  SViewController.m
//  MetalTransition
//
//  Created by ashawn on 11/08/2018.
//  Copyright © 2018 ashawn. All rights reserved.
//

#import "SViewController.h"

@interface SViewController ()<UINavigationControllerDelegate,UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) MetalTransitionShaderType shader;

@end

@implementation SViewController

- (instancetype)initWithShader :(MetalTransitionShaderType)shader {
    if (self = [super init]) {
        self.shader = shader;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"fightclub"]];
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
    
    self.transitioningDelegate = self;
    self.navigationController.delegate = self;
    self.view.backgroundColor = [UIColor greenColor];
    // Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    [self.view addGestureRecognizer: tapGesture];
}

- (void)viewTaped:(UITapGestureRecognizer*)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [MetalTransition transitionWithTransitionType:MetalTransitionTypePresent shader:self.shader];
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [MetalTransition transitionWithTransitionType:MetalTransitionTypeDismiss shader:self.shader];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if(operation == UINavigationControllerOperationPush){
        return [MetalTransition transitionWithTransitionType:MetalTransitionTypePush shader:self.shader];
    }
    else{
        return [MetalTransition transitionWithTransitionType:MetalTransitionTypePop shader:self.shader];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

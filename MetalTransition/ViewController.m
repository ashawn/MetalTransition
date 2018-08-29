//
//  ViewController.m
//  MetalTransition
//
//  Created by ashawn on 11/08/2018.
//  Copyright © 2018 ashawn. All rights reserved.
//

#import "ViewController.h"
#import "SViewController.h"
#import "MetalView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"fightclub"]];
    [self.view addSubview:imageView];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    [self.view addGestureRecognizer: tapGesture];
    
//    MVPMetalView *mvpView = [[MVPMetalView alloc] initWithFrame:self.view.bounds image:[UIImage imageNamed:@"fightclub"]];
//    [self.view addSubview:mvpView];
}

- (void)viewTaped:(UITapGestureRecognizer*)recognizer {
    [self presentViewController:[SViewController new] animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

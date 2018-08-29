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

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray* shaders;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"miao5"]];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.sectionFooterHeight = CGFLOAT_MIN;
    
    [self.view addSubview:tableView];
    
    [self initShaderArr];
}

- (void)initShaderArr {
    self.shaders = [NSArray arrayWithObjects:@(MetalTransitionShaderTypeFade),@(MetalTransitionShaderTypeFold),@(MetalTransitionShaderTypeRipple),@(MetalTransitionShaderTypeHorizontal),@(MetalTransitionShaderTypeWave),@(MetalTransitionShaderTypeCrosswarp),@(MetalTransitionShaderTypeRadial),@(MetalTransitionShaderTypePinwheel), nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table datasouce
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shaders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    cell.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    switch ([self.shaders[indexPath.row] unsignedIntegerValue]) {
        case MetalTransitionShaderTypeFade:
            cell.textLabel.text = @"Fade";
            break;
        case MetalTransitionShaderTypeFold:
            cell.textLabel.text = @"Fold";
            break;
        case MetalTransitionShaderTypeRipple:
            cell.textLabel.text = @"Ripple";
            break;
        case MetalTransitionShaderTypeHorizontal:
            cell.textLabel.text = @"Horizontal";
            break;
        case MetalTransitionShaderTypeWave:
            cell.textLabel.text = @"Wave";
            break;
        case MetalTransitionShaderTypeCrosswarp:
            cell.textLabel.text = @"Crosswarp";
            break;
        case MetalTransitionShaderTypeRadial:
            cell.textLabel.text = @"Radial";
            break;
        case MetalTransitionShaderTypePinwheel:
            cell.textLabel.text = @"Pinwheel";
            break;
        default:
            break;
    }
    
    return cell;
}


#pragma mark - table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self presentViewController:[[SViewController alloc] initWithShader:[self.shaders[indexPath.row] unsignedIntegerValue]] animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end

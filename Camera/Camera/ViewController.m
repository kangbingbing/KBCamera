//
//  ViewController.m
//  Camera
//
//  Created by iMac on 17/7/5.
//  Copyright © 2017年 kangbing. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"
#import "GPUCameraController.h"
#import "GPUImageVideoController.h"

#define WeakSelf __weak typeof(self) weakSelf = self;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}
- (IBAction)gpuimageclick:(id)sender {
    WeakSelf
    GPUCameraController *gpuVC = [[GPUCameraController alloc]init];
    gpuVC.myblock = ^(){
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:gpuVC animated:YES completion:nil];
    
    
}

- (IBAction)btnClick:(id)sender {
    WeakSelf
    CameraViewController *camVC = [[CameraViewController alloc]init];
    camVC.myblock = ^(){
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:camVC animated:YES completion:nil];
    
    
}
- (IBAction)gpuimageVideo:(id)sender {
    WeakSelf
    GPUImageVideoController *videoVC = [[GPUImageVideoController alloc]init];
    videoVC.myblock = ^(){
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:videoVC animated:YES completion:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

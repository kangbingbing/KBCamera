//
//  GPUCameraController.m
//  Camera
//
//  Created by iMac on 17/7/24.
//  Copyright © 2017年 kangbing. All rights reserved.
//

#import "GPUCameraController.h"
#import <GPUImage/GPUImage.h>
#import "GPUImageBeautifyFilter.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface GPUCameraController ()

@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;

@property(nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSMutableArray *filterArray;
@end

@implementation GPUCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.index = 100;
    
    self.videoCamera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    

    _filter = [[GPUImageStretchDistortionFilter alloc] init];
    
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    self.filterView.center = self.view.center;
    
    [self.videoCamera addTarget:_filter];
    [_filter addTarget:self.filterView];
    [self.view addSubview:self.filterView];
    [self.videoCamera startCameraCapture];
    

    UIButton *btn = [[UIButton alloc]init];
    [self.view addSubview:btn];
    btn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 44, 40, 40);
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"flier"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"unflier"] forState:UIControlStateSelected];
    
    UIButton *changeBtn = [[UIButton alloc]init];
    [changeBtn setBackgroundImage:[UIImage imageNamed:@"change"] forState:UIControlStateNormal];
    [self.view addSubview:changeBtn];
    [changeBtn addTarget:self action:@selector(changeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    changeBtn.frame = CGRectMake(100, 44, 44, 44);
    
    UIButton *closeBtn = [[UIButton alloc]init];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.view insertSubview:closeBtn aboveSubview:self.view];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.frame = CGRectMake(20, 44, 44, 44);
    

    
    UIButton *camerabtn = [[UIButton alloc]init];
    [camerabtn setBackgroundImage:[UIImage imageNamed:@"cirle_btn"] forState:UIControlStateNormal];
    [self.view addSubview:camerabtn];
    [camerabtn addTarget:self action:@selector(camera) forControlEvents:UIControlEventTouchUpInside];
    camerabtn.frame = CGRectMake(0, 0, 80, 80);
    camerabtn.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.8);
    
    
    UISwipeGestureRecognizer *pan = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(pangesture:)];
    pan.direction = UISwipeGestureRecognizerDirectionRight;
    [self.filterView addGestureRecognizer:pan];
    
    UISwipeGestureRecognizer *pan1 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(pangesture:)];
    pan1.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.filterView addGestureRecognizer:pan1];
    
    
    
    self.filterArray = [NSMutableArray arrayWithCapacity:10];
    
    
    // 亮度
    GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
    filter.brightness = 0.4;
    
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    // 曝光
    GPUImageExposureFilter *exfilter = [[GPUImageExposureFilter alloc]init];
    //  对比度
    GPUImageContrastFilter *contrafilter = [[GPUImageContrastFilter alloc]init];
    contrafilter.contrast = 1.5;
    
//    * 压花效果 
    GPUImageEmbossFilter *embossfilter = [[GPUImageEmbossFilter alloc]init];
    /** 雾 */
    GPUImageHazeFilter *hazefileter = [[GPUImageHazeFilter alloc]init];
    
    GPUImageBulgeDistortionFilter *bulge = [[GPUImageBulgeDistortionFilter alloc]init];
    bulge.radius = 0.8;
    
    GPUImageCannyEdgeDetectionFilter *cannyFiller = [[GPUImageCannyEdgeDetectionFilter alloc]init];
    
    GPUImageClosingFilter *closingFilter = [[GPUImageClosingFilter alloc]init];
  
    GPUImageSepiaFilter *sepiafilter = [[GPUImageSepiaFilter alloc] init];
    
    GPUImageTiltShiftFilter *tiltfilter = [[GPUImageTiltShiftFilter alloc] init];
    tiltfilter.topFocusLevel = 0.65;
    tiltfilter.bottomFocusLevel = 1.65;
    tiltfilter.blurRadiusInPixels = 1.5;
    tiltfilter.focusFallOffRate = 0.2;
    
    GPUImageSketchFilter *sketchfilter = [[GPUImageSketchFilter alloc] init];
    GPUImageColorInvertFilter *colorfilter = [[GPUImageColorInvertFilter alloc] init];
    GPUImageSmoothToonFilter *toonfilter = [[GPUImageSmoothToonFilter alloc] init];

    [self.filterArray addObject:filter];
    [self.filterArray addObject:exfilter];
    [self.filterArray addObject:beautifyFilter];
    [self.filterArray addObject:contrafilter];
    [self.filterArray addObject:embossfilter];
    [self.filterArray addObject:hazefileter];
    [self.filterArray addObject:bulge];
    [self.filterArray addObject:cannyFiller];
    [self.filterArray addObject:closingFilter];
    [self.filterArray addObject:sepiafilter];
    [self.filterArray addObject:tiltfilter];
    [self.filterArray addObject:sketchfilter];
    [self.filterArray addObject:colorfilter];
    [self.filterArray addObject:toonfilter];

    
    
    
    
    
}


- (void)closeBtnClick{
    
    if (self.myblock) {
        self.myblock();
    }
    
}
- (void)pangesture:(UISwipeGestureRecognizer *)gesture{
    
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        self.index++;
    }else{
        self.index--;
        if (self.index <= 0) {
            self.index = 0;
        }
    }

    NSLog(@"%zd",self.index % self.filterArray.count);
    
    [self.videoCamera removeAllTargets];
    _filter = (GPUImageFilter *)self.filterArray[self.index % self.filterArray.count];
    [self.videoCamera addTarget:_filter];
    [_filter addTarget:self.filterView];
    
}
#pragma mark 照相
- (void)camera{
    
    [self.videoCamera capturePhotoAsImageProcessedUpToFilter:_filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        
       UIImageWriteToSavedPhotosAlbum(processedImage, self, nil, nil);
        
    }];

}

- (void)changeBtnClick{

    [self.videoCamera rotateCamera];

}

#pragma mark 美颜
- (void)btnClick:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [self.videoCamera removeAllTargets];
        [self.videoCamera addTarget:self.filterView];
    }else {
        
        [self.videoCamera removeAllTargets];
        GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
        _filter = (GPUImageFilter *)beautifyFilter;
        [self.videoCamera addTarget:beautifyFilter];
        [beautifyFilter addTarget:self.filterView];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

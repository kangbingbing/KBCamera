//
//  GPUImageVideoController.m
//  Camera
//
//  Created by iMac on 17/7/24.
//  Copyright © 2017年 kangbing. All rights reserved.
//

#import "GPUImageVideoController.h"
#import <GPUImage/GPUImage.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define kScreenW    [UIScreen mainScreen].bounds.size.width
#define kScreenH    [UIScreen mainScreen].bounds.size.height

@interface GPUImageVideoController (){

    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
}

@property (nonatomic, strong) UIButton *btn;

@property (nonatomic, strong) NSURL *movieURL;

@end

@implementation GPUImageVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    filter = [[GPUImageSepiaFilter alloc] init];
    
    //    filter = [[GPUImageTiltShiftFilter alloc] init];
    //    [(GPUImageTiltShiftFilter *)filter setTopFocusLevel:0.65];
    //    [(GPUImageTiltShiftFilter *)filter setBottomFocusLevel:0.85];
    //    [(GPUImageTiltShiftFilter *)filter setBlurSize:1.5];
    //    [(GPUImageTiltShiftFilter *)filter setFocusFallOffRate:0.2];
    
    //    filter = [[GPUImageSketchFilter alloc] init];
    //    filter = [[GPUImageColorInvertFilter alloc] init];
    //    filter = [[GPUImageSmoothToonFilter alloc] init];
    //    GPUImageRotationFilter *rotationFilter = [[GPUImageRotationFilter alloc] initWithRotation:kGPUImageRotateRightFlipVertical];
    
    [videoCamera addTarget:filter];
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    filterView.center = self.view.center;
    [self.view addSubview:filterView];
    //    filterView.fillMode = kGPUImageFillModeStretch;
    //    filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    // Record a movie for 10 s and store it in /Documents, visible via iTunes file sharing
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    movieWriter.encodingLiveVideo = YES;
    //    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    //    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
    //    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1080.0, 1920.0)];
    [filter addTarget:movieWriter];
    [filter addTarget:filterView];
    [videoCamera startCameraCapture];
    _movieURL = movieURL;
    
    
    
    UIButton *btn = [[UIButton alloc]init];
    [btn setBackgroundImage:[UIImage imageNamed:@"cirle_btn"] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnTouInsideClick) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(btnOutClick:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    self.btn = btn;
    btn.frame = CGRectMake(0, 0, 80, 80);
    btn.center = CGPointMake(kScreenW * 0.5, kScreenH * 0.8);
    
    
    UIButton *changeBtn = [[UIButton alloc]init];
    [changeBtn setBackgroundImage:[UIImage imageNamed:@"change"] forState:UIControlStateNormal];
    [self.view addSubview:changeBtn];
    [changeBtn addTarget:self action:@selector(changeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    changeBtn.frame = CGRectMake(100, 44, 38, 38);
    
    UIButton *closeBtn = [[UIButton alloc]init];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.view insertSubview:closeBtn aboveSubview:self.view];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.frame = CGRectMake(20, 44, 38, 38);
    
    

}

- (void)closeBtnClick{
    
    if (self.myblock) {
        self.myblock();
    }
    
}

- (void)changeBtnClick{
    
    [videoCamera rotateCamera];
    
}

- (void)btnTouInsideClick{

    NSLog(@"Start recording");
    videoCamera.audioEncodingTarget = movieWriter;
    [movieWriter startRecording];
}

- (void)btnOutClick:(UIButton *)sender{

    [filter removeTarget:movieWriter];
    videoCamera.audioEncodingTarget = nil;
    [movieWriter finishRecording];
    NSLog(@"Movie completed%@",_movieURL);
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:_movieURL])
    {
        [library writeVideoAtPathToSavedPhotosAlbum:_movieURL completionBlock:^(NSURL *assetURL, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"视频保存失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 } else {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"已保存到相册" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 }
             });
         }];
    }


}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Map UIDeviceOrientation to UIInterfaceOrientation.
    UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
            orient = UIInterfaceOrientationLandscapeLeft;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            orient = UIInterfaceOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationPortrait:
            orient = UIInterfaceOrientationPortrait;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            orient = UIInterfaceOrientationPortraitUpsideDown;
            break;
            
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            // When in doubt, stay the same.
            orient = fromInterfaceOrientation;
            break;
    }
    videoCamera.outputImageOrientation = orient;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES; // Support all orientations.
}



- (void)viewDidUnload
{
    [super viewDidUnload];
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

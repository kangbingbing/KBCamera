//
//  CameraViewController.m
//  Camera
//
//  Created by iMac on 17/7/5.
//  Copyright © 2017年 kangbing. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CirleView.h"


#define kScreenW    [UIScreen mainScreen].bounds.size.width
#define kScreenH    [UIScreen mainScreen].bounds.size.height

@interface CameraViewController ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;

@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIButton *btn;

@property (nonatomic, strong) UIButton *canlebtn;

@property (nonatomic, strong) UIButton *surebtn;

@property (nonatomic, strong) UIView *bgView;
//记录需要保存视频的路径
@property (strong, nonatomic) NSURL *saveVideoUrl;

@property (nonatomic, assign) BOOL isPhoto;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIImageView *placeImg;

@property (nonatomic, strong) UIImage *currentImage;

@property (nonatomic, assign) CGFloat sec;

@property (nonatomic, strong) CirleView *cirleView;

@end

@implementation CameraViewController

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    self.session = [[AVCaptureSession alloc] init];
    //设置分辨率
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    //取得后置摄像头
    AVCaptureDevice *captureDevice;
    
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == AVCaptureDevicePositionBack) {
            captureDevice = camera;
        }
    }
    //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    //初始化输入设备
    NSError *error = nil;
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"错误：%@",error.localizedDescription);
        return;
    }
    
    //添加音频
    error = nil;
    AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"错误原因:%@",error.localizedDescription);
        return;
    }
    
    //输出对象
    self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];//视频输出
    
    //将输入设备添加到会话
    if ([self.session canAddInput:self.captureDeviceInput]) {
        [self.session addInput:self.captureDeviceInput];
        [self.session addInput:audioCaptureDeviceInput];
        //设置视频防抖
        AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoStabilizationSupported]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        }
    }
    
    //将输出设备添加到会话 (刚开始 是照片为输出对象)
    if ([self.session canAddOutput:self.captureMovieFileOutput]) {
        [self.session addOutput:self.captureMovieFileOutput];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    
    UIView *bgView = [[UIView alloc]init];
    self.bgView = bgView;
    bgView.frame = self.view.bounds;
    [self.view addSubview:bgView];
    [self.bgView.layer addSublayer:self.previewLayer];
    [self.session startRunning];
    
    UIButton *btn = [[UIButton alloc]init];
    [btn setBackgroundImage:[UIImage imageNamed:@"cirle_btn"] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(btnOutClick:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    self.btn = btn;
    btn.frame = CGRectMake(0, 0, 80, 80);
    btn.center = CGPointMake(kScreenW * 0.5, kScreenH * 0.8);
    
    UIButton *canlebtn = [[UIButton alloc]init];
    self.canlebtn = canlebtn;
    canlebtn.hidden = YES;
    [canlebtn setBackgroundImage:[UIImage imageNamed:@"error"] forState:UIControlStateNormal];
    [self.view addSubview:canlebtn];
    [canlebtn addTarget:self action:@selector(canlebtnClick) forControlEvents:UIControlEventTouchUpInside];
    canlebtn.frame = CGRectMake(0, 0, 80, 80);
    canlebtn.center = CGPointMake(kScreenW * 0.25, kScreenH * 0.8);
    
    
    UIButton *surebtn = [[UIButton alloc]init];
    self.surebtn = surebtn;
    surebtn.hidden = YES;
    [surebtn setBackgroundImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    [self.view addSubview:surebtn];
    [surebtn addTarget:self action:@selector(surebtnClick) forControlEvents:UIControlEventTouchUpInside];
    surebtn.frame = CGRectMake(0, 0, 80, 80);
    surebtn.center = CGPointMake(kScreenW * 0.75, kScreenH * 0.8);
    
    
    UIImageView *placeImg = [[UIImageView alloc]init];
    self.placeImg = placeImg;
    [self.view addSubview:placeImg];
    placeImg.frame = CGRectMake(kScreenW - 100, 20, 80, 120);
    placeImg.hidden = YES;
    placeImg.backgroundColor = [UIColor redColor];
    
    
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
    
    
}


#pragma mark - 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制...");
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTimeLenth) userInfo:nil repeats:YES];
    _timer = timer;
    self.sec = 0.0;
    [timer fire];
    
}


-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"视频录制完成.");

    self.saveVideoUrl = outputFileURL;
    
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:outputFileURL];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    imageGenerator.appliesPreferredTrackTransform = YES;
    NSError *imageerror = nil;
    CMTime time = CMTimeMake(0,30);
    CMTime actucalTime;
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&imageerror];
    
    CMTimeShow(actucalTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    if (imageerror) {
        NSLog(@"截取视频图片失败");
        _btn.hidden = NO;
        _surebtn.hidden = YES;
        _canlebtn.hidden = YES;
    }else{
    
        if (image) {
            self.placeImg.hidden = NO;
            self.placeImg.image = image;
        }
    }
    
    
    
}


- (void)videoHandlePhoto:(NSURL *)url {
    
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    imageGenerator.appliesPreferredTrackTransform = YES;
    NSError *imageerror = nil;
    CMTime time = CMTimeMake(0,30);
    CMTime actucalTime;
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&imageerror];
    if (imageerror) {
        NSLog(@"截取视频图片失败");
    }
    CMTimeShow(actucalTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    if (image) {
        NSLog(@"保存图片成功");
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"已保存到相册" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"保存图片失败");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"图片保存失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];


}

- (void)canlebtnClick{
    
    _surebtn.hidden = YES;
    _canlebtn.hidden = YES;
    _btn.hidden = NO;
  
    NSLog(@"取消");
    
    self.placeImg.hidden = YES;
    self.currentImage = nil;
    
}

- (void)surebtnClick{
    
    NSLog(@"确定");
    _surebtn.hidden = YES;
    _canlebtn.hidden = YES;
    _btn.hidden = NO;

    
    self.placeImg.hidden = YES;
    self.currentImage = nil;
    
    if (self.saveVideoUrl) {
        
        if (self.isPhoto) {
            
            [self videoHandlePhoto:self.saveVideoUrl];
        }else{
        
            ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
            [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:self.saveVideoUrl completionBlock:^(NSURL *assetURL, NSError *error) {
                
                [[NSFileManager defaultManager] removeItemAtURL:self.saveVideoUrl error:nil];
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"视频保存失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"已保存到相册" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }];
        
        }
    }
    
}

- (void)btnClick{
    
    NSLog(@"点下");
    
    [self.view insertSubview:self.cirleView belowSubview:self.btn];


    AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeAudio];
    //根据连接取得设备输出的数据
    if (![self.captureMovieFileOutput isRecording]) {
        //如果支持多任务则开始多任务
//        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
//            self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
//        }
//        if (self.saveVideoUrl) {
//            [[NSFileManager defaultManager] removeItemAtURL:self.saveVideoUrl error:nil];
//        }
        //预览图层和视频方向保持一致
        connection.videoOrientation = [self.previewLayer connection].videoOrientation;
        NSString *outputFielPath=[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"];
        NSLog(@"save path is :%@",outputFielPath);
        NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
        NSLog(@"fileUrl:%@",fileUrl);
        [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        
    } else {
        [self.captureMovieFileOutput stopRecording];
    }

}

- (void)timerTimeLenth{
    
    self.sec += 0.1;
    self.cirleView.progress = self.sec * 0.1;
    if (self.sec > 10) {
        [self btnOutClick:nil];
    }
    

    
}

- (UIImage *)currentImage{
    if (_currentImage == nil) {
        _currentImage = [[UIImage alloc]init];
    }
    return _currentImage;
}



- (void)changeBtnClick{
    
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;//前
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition = AVCaptureDevicePositionBack;//后
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.session beginConfiguration];
    //移除原有输入对象
    [self.session removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.session canAddInput:toChangeDeviceInput]) {
        [self.session addInput:toChangeDeviceInput];
        self.captureDeviceInput = toChangeDeviceInput;
    }
    //提交会话配置
    [self.session commitConfiguration];
    
    
    
}

-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    //    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
    //        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    //    }];
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}


- (void)closeBtnClick{
    
    if (self.myblock) {
        self.myblock();
    }
    
}

- (CirleView *)cirleView{
    
    if (_cirleView == nil) {
        _cirleView = [[CirleView alloc]init];
        _cirleView.frame = CGRectMake(0, 0, 110, 110);
        _cirleView.center = CGPointMake(kScreenW * 0.5, kScreenH * 0.8);
        _cirleView.backgroundColor = [UIColor clearColor];
    }
    return _cirleView;
}


- (void)btnOutClick:(UIButton *)sender{
    
    _btn.hidden = YES;
    _surebtn.hidden = NO;
    _canlebtn.hidden = NO;
    
    
    [self.cirleView removeFromSuperview];
    self.cirleView = nil;
    
    [_timer invalidate];
    _timer = nil;
    [self.captureMovieFileOutput stopRecording];//停止录制
    
    self.isPhoto = self.sec > 1 ? NO : YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    

    
    
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

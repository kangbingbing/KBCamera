
###### 相机滤镜如图

![](https://ws1.sinaimg.cn/large/9e1008a3ly1fhvxgry8ukj20u01hcqag.jpg =300x420)



### GPUImage 相机

###### GPUImage提供了丰富的滤镜，简单的说就是4步走，

1 初始化相机
	
	// 相机使用 GPUImageStillCamera
	self.videoCamera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
	

2 初始化滤镜

	_mFilter = [[GPUImageStretchDistortionFilter alloc] init];

3 创建预览层并把滤镜输出至预览

	self.filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
	[_mFilter addTarget:self.filterView];

4 相机获取视频数据输出到滤镜

	[self.videoCamera addTarget:_mFilter];
	[self.videoCamera startCameraCapture];
	

切换滤镜的操作
	
	// 移除之前滤镜
	[self.videoCamera removeAllTargets];
    _mFilter = (GPUImageFilter *)self.fillerArray[self.index % self.fillerArray.count];
    [self.videoCamera addTarget:_mFilter];
    [_mFilter addTarget:self.filterView];
    
    
##### 基于GPUImga的相机滤镜

![GPUImga相机滤镜](https://ws1.sinaimg.cn/large/9e1008a3ly1fhvxinhp0og209o0h0e86.gif)



### GPUImage 录像

	录像使用GPUImageVideoCamera
	videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    filter = [[GPUImageSepiaFilter alloc] init];
    [videoCamera addTarget:filter];
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    filterView.center = self.view.center;
    [self.view addSubview:filterView];
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    movieWriter.encodingLiveVideo = YES;
    
    [filter addTarget:movieWriter];
    [filter addTarget:filterView];
    [videoCamera startCameraCapture];
    _movieURL = movieURL;
    
开始录像的操作

	videoCamera.audioEncodingTarget = movieWriter;
    [movieWriter startRecording];


结束录像并保存到相册

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
    
###### 基于GPUImga的录像滤镜

![](https://ws1.sinaimg.cn/large/9e1008a3ly1fhvxjo9v3sg209o0h0kjp.gif)


### 模仿微信相机
![模仿微信相机](https://ws1.sinaimg.cn/large/9e1008a3ly1fhvxht8p2wg209o0h07wo.gif)








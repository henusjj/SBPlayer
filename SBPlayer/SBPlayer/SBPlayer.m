//
//  SBPlayer.m
//  SBPlayer
//
//  Created by sycf_ios on 2016/11/17.
//  Copyright © 2016年 sycf_ios. All rights reserved.
//

#import "SBPlayer.h"

@interface SBPlayer ()<SBPlayerControlSliderDelegate,SBPlayerPlayPausedViewDelegate>
{
    NSURL *_url;
    NSTimer *_timer;
}
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *item;
//总时长
@property (nonatomic,assign) CGFloat totalDuration;
//转换后的时间
@property (nonatomic,copy) NSString *totalTime;
//当前播放位置
@property (nonatomic,assign) CMTime currenTime;
//监听播放值
@property (nonatomic,strong) id playbackTimerObserver;
//全屏控制器
@property (nonatomic,strong) UIViewController *fullVC;
//全屏播放器
@property (nonatomic,strong) SBPlayer *fullScreenPlayer;
@end
@implementation SBPlayer
- (instancetype)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url=url;
        [self initAsset];
        [self setupPlayer];
    }
    return self;
}
- (instancetype)initWithURLAsset:(AVURLAsset *)asset{
    self=[super init];
    if (self) {
        self.assert=asset;
        [self setupPlayer];
    }
    return self;
}
-(void)setupPlayer{
    [self configPlayer];
    [self addPlayPausedView];
    [self addPlayerControl];
    [self addPlayerLoading];
    [self addGesture];
    [self addKVO];
    [self addNotification];
}
+(Class)layerClass{
    return [AVPlayerLayer class];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame=self.bounds;
}

#pragma mark - ConfigPlayer
-(void)initAsset{
    if (_url) {
        self.assert=[[AVURLAsset alloc]initWithURL:_url options:nil];
    }
}
//配置播放器
-(void)configPlayer{
    self.backgroundColor=[UIColor blackColor];
    self.item=[AVPlayerItem playerItemWithAsset:self.assert];
    self.player=[[AVPlayer alloc]init];
    [self.player replaceCurrentItemWithPlayerItem:self.item];
    self.player.usesExternalPlaybackWhileExternalScreenIsActive=YES;
    self.playerLayer=[[AVPlayerLayer alloc]init];
    self.playerLayer.backgroundColor=[UIColor blackColor].CGColor;
    self.playerLayer.player=self.player;
    self.playerLayer.frame=self.bounds;
    [self.playerLayer displayIfNeeded];
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    self.playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;
}
#pragma mark - addPlayerControl
//添加播放控制器
-(void)addPlayerControl{
    self.playerControl=[[SBPlayerControl alloc]init];
    self.playerControl.minValue=0.0f;
    self.playerControl.delegate=self;
    //设置播放控制器的背景颜色
    self.playerControl.backgroundColor=[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:0.5];
    NSLog(@"self.totalDuration:%f",self.totalDuration);
    [self addSubview:self.playerControl];
    [self.playerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).priorityHigh();
        make.left.mas_equalTo(self.mas_left);
        make.right.mas_equalTo(self.mas_right);
        make.height.mas_equalTo(@(controlHeight));
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.playerControl.hidden=YES;
}
//添加加载视图
-(void)addPlayerLoading{
    self.loadingView=[[SBPlayerLoading alloc]init];
    self.loadingView.hidden=YES;
    [self addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(controlHeight, controlHeight));
    }];
    
}
//添加暂停时的插图
-(void)addPlayPausedView{
    self.playPausedView=[self createPlayPausedView];
    self.playPausedView.state=SBControlStateNormal;
    [self.playPausedView show];
}
-(SBPlayerPlayPausedView *)createPlayPausedView{
    SBPlayerPlayPausedView *tmpView=[[SBPlayerPlayPausedView alloc]init];
    tmpView.delegate=self;
    [self addSubview:tmpView];
    [tmpView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    return tmpView;
}
//添加手势
-(void)addGesture{
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
}
//点击播放器手势事件
-(void)tapAction:(UITapGestureRecognizer *)gesture{
    if ([self.playerControl isHidden]) {
        self.playerControl.hidden=NO;
        [self addPlayerControlTimer];
    }else{
        [self hideOrShowPauseView];
    }
}
//显示或者隐藏暂停按键
-(void)hideOrShowPauseView{
    if (!_isNormal) {
        self.playPausedView.state=SBControlStateNormal;
        [self.playPausedView hide];
        [self.player play];
    }else{
        self.playPausedView.state=SBControlStateSelected;
        [self.playPausedView show];
        [self.player pause];
    }
    self.playerControl.hidden=NO;
    if (kScreenWidth<kScreenHeight){
        self.playPausedView.backBtn.hidden=YES;
    }else{
        self.playPausedView.backBtn.hidden=NO;
    }
    self.playPausedView.title.hidden=NO;
    [self addPlayerControlTimer];
    _isNormal=!_isNormal;
}
-(void)addPlayerControlTimer{
    if (_timer) {
        return;
    }
    _timer=[NSTimer scheduledTimerWithTimeInterval:5.f repeats:NO block:^(NSTimer * _Nonnull timer) {
        if (![self.playerControl isHidden]) {
            self.playerControl.hidden=YES;
            _timer=nil;
        }
    }];
}
-(void)addKVO{
    //监听状态属性
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监听网络加载情况属性
    [self.item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //监听播放的区域缓存是否为空
    [self.item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓存可以播放的时候调用
    [self.item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    //监听暂停或者播放中
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerControl addObserver:self forKeyPath:@"scalling" options:NSKeyValueObservingOptionNew context:nil];
    [self.playPausedView addObserver:self forKeyPath:@"backBtnTouched" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status=[[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        switch (status) {
            case AVPlayerStatusUnknown:{
                NSLog(@"未知状态");
                self.state=SBPlayerStateBuffering;
            }
                break;
            case AVPlayerStatusReadyToPlay:{
                NSLog(@"开始播放状态");
                self.state=SBPlayerStatePlaying;
                //总时长
                self.totalDuration=self.item.duration.value/self.item.duration.timescale;
                //转换成时间格式的总时长
                self.totalTime=[self convertTime:self.totalDuration];
                //总时间
                self.playerControl.totalTimeLabel.text=self.totalTime;
                self.playPausedView.totalTime.text=self.totalTime;
                //设置播放控制器进度最大值和最小值
                self.playerControl.minValue=0;
                self.playerControl.maxValue=self.totalDuration;
                [self addTimer];
                if (self.loadingView) {
                    [self.loadingView hide];
                    [self.loadingView removeFromSuperview];
                }
            }
                break;
            case AVPlayerStatusFailed:
                self.state=SBPlayerStateFailed;
                
                NSLog(@"播放失败");
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度
        NSArray *loadedTimeRanges = [self.item loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
        CMTime duration = self.item.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        //缓存值
        self.playerControl.bufferValue=timeInterval / totalDuration;
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        self.state=SBPlayerStateBuffering;
        NSLog(@"缓冲不足暂停");
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        NSLog(@"缓冲达到可播放");
    } else if ([keyPath isEqualToString:@"rate"]){//当rate==0时为暂停,rate==1时为播放,当rate等于负数时为回放
        if ([[change objectForKey:NSKeyValueChangeNewKey]integerValue]==0) {
            _isPlaying=false;
        }else{
            _isPlaying=true;
        }
    } else if ([keyPath isEqualToString:@"timeControlStatus"]){
        //timeControlStatus==0是暂停,==1时播放
        NSLog(@"timeControlStatus:%@",[change objectForKey:NSKeyValueChangeNewKey]);
        if ([[change objectForKey:NSKeyValueChangeNewKey]integerValue]==1) {
            [self.loadingView show];
        }else{
            [self.loadingView hide];
        }
    }else if ([keyPath isEqualToString:@"scalling"]){
        //全屏或者小屏
        if (kScreenWidth<kScreenHeight) {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
            self.playPausedView.title.hidden=NO;
        }else{
            [self interfaceOrientation:UIInterfaceOrientationPortrait];
        }

    }else if ([keyPath isEqualToString:@"backBtnTouched"]){
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
}

-(void)addNotification{
    //监听当视频播放结束时
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SBPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    //监听当视频开始或快进或者慢进或者跳过某段播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SBPlayerItemTimeJumpedNotification:) name:AVPlayerItemTimeJumpedNotification object:[self.player currentItem]];
    //监听播放失败时
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SBPlayerItemFailedToPlayToEndTimeNotification:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SBPlayerItemPlaybackStalledNotification:) name:AVPlayerItemPlaybackStalledNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SBPlayerItemNewAccessLogEntryNotification:) name:AVPlayerItemNewAccessLogEntryNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SBPlayerItemNewErrorLogEntryNotification:) name:AVPlayerItemNewErrorLogEntryNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SBPlayerItemFailedToPlayToEndTimeErrorKey:) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
-(void)SBPlayerItemDidPlayToEndTimeNotification:(NSNotification *)notification{
    NSLog(@"%s",__FUNCTION__);
    [self.item seekToTime:kCMTimeZero];
    [self.player pause];
    _isNormal=0;
    [self addPlayPausedView];
    
}
-(void)SBPlayerItemTimeJumpedNotification:(NSNotification *)notification{
    NSLog(@"%s",__FUNCTION__);
}
-(void)SBPlayerItemFailedToPlayToEndTimeNotification:(NSNotification *)notification{
    NSLog(@"%s",__FUNCTION__);
}
-(void)SBPlayerItemPlaybackStalledNotification:(NSNotification *)notification{
    NSLog(@"%s",__FUNCTION__);
}
-(void)SBPlayerItemNewAccessLogEntryNotification:(NSNotification *)notification{
    NSLog(@"%s",__FUNCTION__);
}
-(void)SBPlayerItemNewErrorLogEntryNotification:(NSNotification *)notification{
    NSLog(@"%s",__FUNCTION__);
}
-(void)SBPlayerItemFailedToPlayToEndTimeErrorKey:(NSNotification *)notification{
    NSLog(@"%s",__FUNCTION__);
}
//设置title
-(void)setTitle:(NSString *)title{
    self.playPausedView.title.text=title;
}
//将数值转换成时间
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

//监听视频播放时间
-(void)addTimer{
    //设置间隔时间
    CMTime interval=CMTimeMake(1.f, 1.f);
    __weak typeof(self) weakSelf=self;
    self.playbackTimerObserver=[weakSelf.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //使进度条跟着视频播放前进
        CGFloat currentValue=self.item.currentTime.value/self.item.currentTime.timescale;
        self.playerControl.currentValue=currentValue;
        self.playerControl.trackingTimeLabel.text=[self convertTime:currentValue];
        NSLog(@"%f",currentValue);
    }];
}
#pragma mark - SBPlayerControlSliderDelegate

-(void)sendCurrentValueToPlayer:(CGFloat)value{
    //获取进度条所在位置值的时间
    self.currenTime=CMTimeMake(value*self.item.duration.timescale, self.item.duration.timescale);
    [self.player seekToTime:self.currenTime];
}
#pragma mark - SBPlayerPlayPausedViewDelegate
-(void)sendPlayOrPausedValueToPlayer{
    [self hideOrShowPauseView];
}

-(void)setNeedsDisplay{
    NSLog(@"%s",__FUNCTION__);
    
}
//设置播放器大小
-(void)setFrame:(CGRect)frame{
    self.playerLayer.frame=frame;
}
//获取当前时间
-(CMTime)currentTime{
    return self.item.currentTime;
}
//设置视频填充模式
-(void)setContentMode:(SBPlayerContentMode)contentMode{
    switch (contentMode) {
        case SBPlayerContentModeResizeFit:
            self.playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;
            break;
        case SBPlayerContentModeResizeFitFill:
            self.playerLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
            break;
        case SBPlayerContentModeResize:
            self.playerLayer.videoGravity=AVLayerVideoGravityResize;
            break;
    }
}

- (void)deviceOrientationDidChange: (NSNotification *)notification
{
    UIInterfaceOrientation _interfaceOrientation=[[UIApplication sharedApplication]statusBarOrientation];
    switch (_interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            self.fullVC=[self pushToFullScreen];
            [self.player pause];
            [self.fullScreenPlayer seekToTime:self.item.currentTime];
            [[self getCurrentVC] presentViewController:self.fullVC animated:YES completion:nil];
        }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
        {
            
            if (self.fullVC) {
                if (self.fullScreenPlayer.isPlaying) {
                    [self.player play];
                    [self.playPausedView hide];
                }else{
                    [self pause];
                    _isNormal=1;
                    [self hideOrShowPauseView];
                }
                if (self.fullScreenPlayer.item.currentTime.value/self.fullScreenPlayer.item.currentTime.timescale>0) {
                    [self.player seekToTime:self.fullScreenPlayer.currentTime];
                }
                [self.fullScreenPlayer remove];
                self.fullScreenPlayer=nil;
                [self.fullVC dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
        case UIInterfaceOrientationUnknown:
            NSLog(@"UIInterfaceOrientationLandscapePortial");
            break;
    }
}
//推入全屏
-(UIViewController *)pushToFullScreen{
    UIViewController *vc=[[UIViewController alloc]init];
    [[self getCurrentVC] prefersStatusBarHidden];
    self.fullScreenPlayer=[[SBPlayer alloc]initWithURLAsset:self.assert];
    [vc.view addSubview:self.fullScreenPlayer];
    [self.fullScreenPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(vc.view);
    }];
    if (_isPlaying) {
        [self.fullScreenPlayer play];
        [self.fullScreenPlayer.playPausedView hide];
    }else{
        [self.fullScreenPlayer pause];
    }
    [self.fullScreenPlayer setTitle:self.playPausedView.title.text];
    return vc;
    
}
//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
}
-(void)seekToTime:(CMTime)time{
    [self.item seekToTime:time];
}
-(void)play{
    if (self.player!=nil ) {
        [self.playerLayer isReadyForDisplay];
        [self.player play];
    }
}
-(void)pause{
    if (self.player!=nil ) {
        [self.player pause];
    }
}
-(void)stop{
    [self.item seekToTime:kCMTimeZero];
    [self.player pause];
    _isNormal=0;
    [self addPlayPausedView];
}
//旋转方向
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;

        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    if (orientation == UIInterfaceOrientationLandscapeRight||orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
    }
}
-(void)remove{
    [self.item removeObserver:self forKeyPath:@"status"];
    [self.item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
    [self.playerControl removeObserver:self forKeyPath:@"scalling"];
    [self.player removeTimeObserver:self.playbackTimerObserver];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemTimeJumpedNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemTimeJumpedNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemNewAccessLogEntryNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemNewErrorLogEntryNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self.item seekToTime:kCMTimeZero];
    self.assert=nil;
    [self.player setRate:0];
    [self.player pause];
    self.item=nil;
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.playerLayer.player=nil;
    self.totalDuration=0;
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.playerLayer removeFromSuperlayer];
    [self removeFromSuperview];
}
-(void)dealloc{
    [self remove];
}
@end

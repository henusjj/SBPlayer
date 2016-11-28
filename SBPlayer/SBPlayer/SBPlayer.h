//
//  SBPlayer.h
//  SBPlayer
//
//  Created by sycf_ios on 2016/11/17.
//  Copyright © 2016年 sycf_ios. All rights reserved.
//

#import "SBView.h"
#import "SBPlayerLoading.h"
#import <AVFoundation/AVFoundation.h>
#import "SBPlayerControl.h"
#import "SBPlayerPlayPausedView.h"
/**
 设置视频播放填充模式
 */
typedef NS_ENUM(NSInteger,SBPlayerContentMode) {
    SBPlayerContentModeResizeFit,//尺寸适合
    SBPlayerContentModeResizeFitFill,//填充视图
    SBPlayerContentModeResize,//默认
};
typedef NS_ENUM(NSInteger,SBPlayerState) {
    SBPlayerStateFailed,        // 播放失败
    SBPlayerStateBuffering,     // 缓冲中
    SBPlayerStatePlaying,       // 播放中
    SBPlayerStateStopped,        //停止播放
};

@interface SBPlayer : SBView

//当视频没有播放为0,播放后是1
@property (nonatomic,assign) NSInteger isNormal;
//加载的image;
@property (nonatomic,strong) UIImageView *imageViewLogin;
//视频填充模式
@property (nonatomic,assign) SBPlayerContentMode contentMode;
//播放状态
@property (nonatomic,assign) SBPlayerState state;
//加载视图
@property (nonatomic,strong) SBPlayerLoading *loadingView;
//是否正在播放
@property (nonatomic,assign,readonly) BOOL isPlaying;
//暂停时的插图
@property (nonatomic,strong) SBPlayerPlayPausedView *playPausedView;
//urlAsset
@property (nonatomic,strong) AVURLAsset *assert;
//当前时间
@property (nonatomic,assign) CMTime currentTime;
//播放器控制视图
@property (nonatomic,strong) SBPlayerControl *playerControl;
//初始化
- (instancetype)initWithUrl:(NSURL *)url;
- (instancetype)initWithURLAsset:(AVURLAsset *)asset;
//设置标题
-(void)setTitle:(NSString *)title;
//跳到某个播放时间段
-(void)seekToTime:(CMTime)time;
//播放
-(void)play;
//暂停
-(void)pause;
//停止
-(void)stop;
//移除监听,notification,dealloc
-(void)remove;
//显示或者隐藏暂停按键
-(void)hideOrShowPauseView;
@end

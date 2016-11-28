//
//  SBPlayerControl.h
//  SBPlayer
//
//  Created by sycf_ios on 2016/11/18.
//  Copyright © 2016年 sycf_ios. All rights reserved.
//

#import "SBView.h"
//播放控制器进度条代理方法
@protocol SBPlayerControlSliderDelegate<NSObject>
//发送进度条当前值
-(void)sendCurrentValueToPlayer:(CGFloat)value;
@end
typedef NS_ENUM(NSInteger,SBPlayerControlScalling) {
    SBPlayerControlScallingNormal,
    SBPlayerControlScallingLarge,//全屏
};
@interface SBPlayerControl : SBView
//进度条最小值
@property (nonatomic,assign) CGFloat minValue;
//进度条最大值
@property (nonatomic,assign) CGFloat maxValue;
//当前值
@property (nonatomic,assign) CGFloat currentValue;
//缓冲值
@property (nonatomic,assign) CGFloat bufferValue;
//当前播放时间
@property (nonatomic,strong) UILabel *trackingTimeLabel;
//最大时间Label
@property (nonatomic,strong) UILabel *totalTimeLabel;

@property (nonatomic,assign) SBPlayerControlScalling scalling;

@property (nonatomic,weak) id<SBPlayerControlSliderDelegate> delegate;

@end

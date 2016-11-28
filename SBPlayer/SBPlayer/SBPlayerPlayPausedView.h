//
//  SBPlayerPlayPausedView.h
//  SBPlayer
//
//  Created by sycf_ios on 2016/11/22.
//  Copyright © 2016年 sycf_ios. All rights reserved.
//

#import "SBView.h"
@protocol SBPlayerPlayPausedViewDelegate<NSObject>
@required
-(void)sendPlayOrPausedValueToPlayer;
@end
typedef NS_ENUM(NSInteger,SBPlayerControlState) {
    SBControlStateNormal,
    SBControlStateSelected,
};
@interface SBPlayerPlayPausedView : SBView
@property (nonatomic,strong) UIButton *playPauseBtn;
@property (nonatomic,assign) SBPlayerControlState state;
@property (nonatomic,weak) id<SBPlayerPlayPausedViewDelegate> delegate;
@property (nonatomic,assign) NSInteger backBtnTouched;

//总时间
@property (nonatomic,strong) UILabel *totalTime;
//标题
@property (nonatomic,strong) UILabel *title;
//返回
@property (nonatomic,strong) UIButton *backBtn;
-(void)show;
-(void)hide;
@end

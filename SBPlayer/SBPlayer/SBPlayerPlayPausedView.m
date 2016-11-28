//
//  SBPlayerPlayPausedView.m
//  SBPlayer
//
//  Created by sycf_ios on 2016/11/22.
//  Copyright © 2016年 sycf_ios. All rights reserved.
//

#import "SBPlayerPlayPausedView.h"

@implementation SBPlayerPlayPausedView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}
-(void)setupUI{
    self.playPauseBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    self.playPauseBtn.contentMode=UIViewContentModeScaleToFill;
    [self.playPauseBtn addTarget:self action:@selector(pauseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playPauseBtn];
    [self.playPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    self.hidden=YES;
    //添加总时间
    self.totalTime=[[UILabel alloc]init];
    self.totalTime.backgroundColor=[UIColor darkGrayColor];
    self.totalTime.textColor=[UIColor whiteColor];
    self.totalTime.font=[UIFont systemFontOfSize:13];
    self.totalTime.layer.cornerRadius=5;
    self.totalTime.layer.masksToBounds=YES;
    [self addSubview:self.totalTime];
    [self.totalTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(-20);
        make.right.mas_equalTo(self).offset(-20);
    }];
    self.totalTime.hidden=YES;
    //添加title
    self.title=[[UILabel alloc]init];
    self.title.textAlignment=NSTextAlignmentCenter;
    self.title.textColor=[UIColor whiteColor];
    self.title.font=[UIFont systemFontOfSize:16];
    self.title.hidden=YES;
    [self addSubview:self.title];
    //添加返回Button
    self.backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:[UIImage imageNamed:@"Source.bundle/feed_right_arrow"] forState:UIControlStateNormal];
    [self.backBtn setImage:[UIImage imageNamed:@"Source.bundle/collection_topbar_icon_back_normal"] forState:UIControlStateHighlighted];
    [self.backBtn addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backBtn];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self.backBtn.mas_right).offset(10);
        make.right.mas_equalTo(self).offset(-60);
        make.centerY.mas_equalTo(self.backBtn);
    }];

    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self).priorityHigh();
        make.size.mas_equalTo(CGSizeMake(64, 64));
    }];
    self.backBtn.hidden=YES;
}
-(void)buttonTouched:(UIButton *)button{
    self.backBtnTouched=1;
}
-(void)pauseBtnClicked:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(sendPlayOrPausedValueToPlayer)]) {
        [self.delegate sendPlayOrPausedValueToPlayer];
    }
}
-(void)setState:(SBPlayerControlState)state
{
    switch (state) {
        case SBControlStateNormal:{
            self.playPauseBtn.selected=NO;
            [self.playPauseBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
            [self.playPauseBtn setImage:[UIImage imageNamed:@"Source.bundle/Play"] forState:UIControlStateNormal];
            self.totalTime.hidden=NO;
            self.title.hidden=NO;
            self.backBtn.hidden=YES;
        }
            break;
        case SBControlStateSelected:{
            self.playPauseBtn.selected=YES;
            [self.playPauseBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [self.playPauseBtn setImage:[UIImage imageNamed:@"Source.bundle/Pause"] forState:UIControlStateSelected];
            self.totalTime.hidden=YES;
            self.title.hidden=NO;
        }
            break;
    }
}
-(void)show{
    self.title.hidden=NO;
    self.hidden=NO;
}
-(void)hide{
    self.hidden=YES;
}
@end

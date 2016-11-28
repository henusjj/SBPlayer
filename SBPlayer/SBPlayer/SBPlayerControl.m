//
//  SBPlayerControl.m
//  SBPlayer
//
//  Created by sycf_ios on 2016/11/18.
//  Copyright © 2016年 sycf_ios. All rights reserved.
//

#import "SBPlayerControl.h"
#import <sys/utsname.h>
@interface SBPlayerControl ()
//进度条
@property (nonatomic,strong) UISlider *progressSlider;
//全屏按钮
@property (nonatomic,strong) UIButton *largeSmallBtn;
//缓冲进度条
@property (nonatomic,strong) UIProgressView *bufferProgressView;

@end

static const CGFloat padding=10.f;

@implementation SBPlayerControl
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}
-(void)setupUI{
    //缓冲进度条
    self.bufferProgressView=[[UIProgressView alloc]init];
    self.bufferProgressView.progressTintColor=[UIColor whiteColor];
    self.bufferProgressView.trackTintColor=[UIColor lightGrayColor];
    [self addSubview:self.bufferProgressView];
    //进度条
    self.progressSlider=[[UISlider alloc]init];
    [self.progressSlider addTarget:self action:@selector(progressValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.progressSlider.minimumTrackTintColor=[UIColor redColor];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"Source.bundle/thumbNormal"] forState:UIControlStateNormal];
    [self.progressSlider setMaximumTrackTintColor:[UIColor clearColor]];
    self.progressSlider.value=0;
    [self addSubview:self.progressSlider];
    //全屏按钮
    self.largeSmallBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.largeSmallBtn setImage:[UIImage imageNamed:@"Source.bundle/fangda_on"] forState:UIControlStateNormal];
    [self.largeSmallBtn setImage:[UIImage imageNamed:@"Source.bundle/fangda_down"] forState:UIControlStateHighlighted];
    [self.largeSmallBtn addTarget:self action:@selector(scallingChange:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.largeSmallBtn];
    //初始时间
    self.trackingTimeLabel=[self createLabel];
    //最大时间
    self.totalTimeLabel=[self createLabel];
    //给上面几个控件添加约束
    [self addConstraintWith:self.progressSlider button:self.largeSmallBtn trackingLabel:self.trackingTimeLabel andTotalTimeLabel:self.totalTimeLabel withBufferView:self.bufferProgressView];
}
-(UILabel *)createLabel{
    UILabel *label=[[UILabel alloc]init];
    label.text=@"00:00";
    label.textColor=[UIColor whiteColor];
    label.font=[UIFont systemFontOfSize:13];
    [self addSubview:label];
    return label;
}

//添加约束
-(void)addConstraintWith:(UISlider *)sliderView button:(UIButton *)button trackingLabel:(UILabel *)trackingLabel andTotalTimeLabel:(UILabel *)totalTimeLabel withBufferView:(UIProgressView *)bufferView{
    [sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.trackingTimeLabel.mas_right).offset(padding);
        make.bottom.mas_equalTo(self);
        make.right.mas_equalTo(totalTimeLabel.mas_left).offset(-padding);
        make.height.mas_equalTo(@(controlHeight));
    }];
    [bufferView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(sliderView);
        make.left.right.mas_equalTo(sliderView);
        if ([self underIphone5s]) {
            make.height.mas_equalTo(@(0.5f));
        }else{
            make.height.mas_equalTo(@1);
        }
    }];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self).priorityHigh();
        make.left.mas_equalTo(totalTimeLabel.mas_right).priorityHigh();
        make.size.mas_equalTo(CGSizeMake(controlHeight, controlHeight));
    }];
    [trackingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self);
        make.right.mas_equalTo(self.progressSlider.mas_left).offset(-padding);
        make.height.mas_equalTo(@(controlHeight));
        make.left.mas_equalTo(self).offset(padding);
    }];
    [totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self);
        make.right.mas_equalTo(button.mas_left);
        make.height.mas_equalTo(@(controlHeight));
        make.left.mas_equalTo(sliderView.mas_right).offset(padding);
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    NSLog(@"****%@",NSStringFromCGRect(self.largeSmallBtn.frame));
}
-(void)progressValueChanged:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(sendCurrentValueToPlayer:)]) {
        [self.delegate sendCurrentValueToPlayer:self.progressSlider.value];
    }
}
-(void)scallingChange:(UIButton *)button{
    button.selected=!button.selected;
    if (button.selected) {
        self.scalling=SBPlayerControlScallingLarge;
    }else{
        self.scalling=SBPlayerControlScallingNormal;
    }
    
}
-(BOOL)underIphone5s{
    //判断手机尺寸是否为4寸及以下
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    NSLog(@"^^^^^^^^^^^^^^^^%@",platform);
    if ([platform containsString:@"iPhone"]) {
        NSString *subString=[platform substringFromIndex:6];
        if ([subString isEqualToString:@"iPhone8,4"]) {
            return true;
        }
        if (subString.integerValue<7) {
            return true;
        }
    }
    return false;
}
-(void)setMinValue:(CGFloat)minValue{
    self.progressSlider.minimumValue=minValue;
}
-(void)setMaxValue:(CGFloat)maxValue{
    self.progressSlider.maximumValue=maxValue;
}
-(void)setCurrentValue:(CGFloat)currentValue{
    self.progressSlider.value=currentValue;
}
-(void)setBufferValue:(CGFloat)bufferValue{
    self.bufferProgressView.progress=bufferValue;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

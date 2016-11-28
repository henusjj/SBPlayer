//
//  SBPlayerLoading.m
//  SBPlayer
//
//  Created by sycf_ios on 2016/11/17.
//  Copyright © 2016年 sycf_ios. All rights reserved.
//

#import "SBPlayerLoading.h"
#import <Masonry.h>
//间隔时间
#define duration 1.0f
//加载图片名
#define kLoadingImageName @"Source.bundle/collection_loading"
@interface SBPlayerLoading (){
    NSTimer *_timer;//定时器
}
@property (nonatomic,strong) UIImageView *loadingImage;//加载时的图片
@end
@implementation SBPlayerLoading
//初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.loadingImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:kLoadingImageName]];
        self.loadingImage.contentMode=UIViewContentModeScaleAspectFill;
        [self addSubview:self.loadingImage];
        [self addConstraintWithView:self.loadingImage];
    }
    return self;
}
//添加约束
-(void)addConstraintWithView:(UIImageView *)imageView{
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
//显示
-(void)show{
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer=nil;
    }
    self.hidden=NO;
    _timer=[NSTimer timerWithTimeInterval:duration/2 target:self selector:@selector(rotationImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSDefaultRunLoopMode];
}
//旋转图片
-(void)rotationImage{
    
    [UIView animateWithDuration:duration animations:^{
        self.loadingImage.transform=CGAffineTransformRotate(self.loadingImage.transform, M_PI);
    }];
}
//隐藏
-(void)hide{
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer=nil;
    }
    self.hidden=YES;
}

@end

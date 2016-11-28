//
//  ViewController.m
//  SBPlayer
//
//  Created by sycf_ios on 2016/11/17.
//  Copyright © 2016年 sycf_ios. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "SBPlayer.h"
@interface ViewController ()
@property (nonatomic,strong) SBPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player=[[SBPlayer alloc]initWithUrl:[self url]];
    //设置视频标题
    [self.player setTitle:@"这是一个标题"];
    [self.view addSubview:self.player];
    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(self.view);
        make.height.mas_equalTo(@250);
        make.center.mas_equalTo(self.view);
    }];
    
}
-(NSURL *)url {
    NSURL *url=[NSURL URLWithString:@"http://download.3g.joy.cn/video/236/60236937/1451280942752_hd.mp4"];
    return url;
}


@end

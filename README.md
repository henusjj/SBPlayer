# SBPlayer
####基于AVPlayer封装的轻量级播放器,可以播放本地网络视频,易于定制
#####SBPlayer结构简单,可以`横屏竖屏`,支持`M3u8、mp3、flv`等格式视频本地播放或者网络播放,通过masonry约束，适配各种尺寸iPhone。
![1](https://github.com/shibiao/SBPlayer/blob/master/Images/2.gif)
![2](https://github.com/shibiao/SBPlayer/blob/master/Images/3.gif)
![3](https://github.com/shibiao/SBPlayer/blob/master/Images/4.gif)
***
####使用方法：
#####*导入` #import "SBPlayer" `,使用如下，方便简单

```javascript
{
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
```
* 邮件(956035125#qq.com, 把#换成@)
* QQ: 956035125
* github: [github](https://github.com/shibiao)

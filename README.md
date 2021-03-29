# PLVRtmpDemo

[![build passing](https://img.shields.io/badge/build-passing-brightgreen.svg)](#)
[![GitHub release](https://img.shields.io/badge/release-v2.2.4-blue.svg)](https://github.com/easefun/PLVLiveDemo/releases/tag/v2.3.0)

本项目从属于广州易方信息科技股份有限公司旗下的POLYV保利威视频云核心产品“云直播”，展示了如何使用保利威 PLVLiveKit、PolyvLiveAPI、PolyvBusinessSDK 这三个 SDK 实现视频直播、聊天室功能。想要集成本项目提供的 SDK 或使用本 demo，需要在[保利威视频云平台](http://www.polyv.net/)注册账号，并开通相关服务。

本项目包含如下功能：选择推流清晰度、选择横竖屏推流、支持美颜、支持切换前后置摄像头。

### 1 试用

[点击安装内测版](https://www.pgyer.com/Tmmv)，或扫描下方二维码使用 Safari 安装，安装密码：polyv。

![GitHub set up-w140](https://static.pgyer.com/app/qrcode/Tmmv)

也可通过 AppStore 安装正式版：[Polyv 云直播](https://apps.apple.com/cn/app/polyv-%E4%BA%91%E7%9B%B4%E6%92%AD/id1178906547)。

### 2 运行环境

本文档为技术文档，需要阅读者具备基本的 iOS 开发能力，且需要配置苹果的开发环境。

- Mac OS 10.10+
- Xcode 9.0+
- CocoaPods 1.7.0+

### 3 安装运行

1. 下载当前项目至本地
2. 进入 PolyvRtmpDemo 目录，执行 `pod install` 或 `pod update`
3. 打开生成的 `.xcworkspace` 文件，编译、运行即可

### 4 项目结构

```
├── PLVRtmpDemo
│   ├── AppDelegate
│   ├── Main // 首页/登录页
│   │   └── Main.storyboard
│   │   ├── PLVLoginViewController
│   ├── Setting // 设置页
│   │   ├── PLVLiveSettingViewController
│   ├── Live  // 直播页
│   │   ├── PLVLiveViewController
│   ├── Supporting Files
│   ├── Library
│   ├── Util
│   └── Category
├── PLVRtmpDemo.xcodeproj
├── Podfile  // 依赖库配置文件
├── Podfile.lock
├── Pods     // 依赖库
├── PLVRtmpDemo.xcodeproj
└── PLVRtmpDemo.xcworkspace
```

### 5 依赖库

使用 CocoaPods 将各个依赖库集成到项目中。首先，在项目中新建一个 Podfile 文件，添加以下内容

```ruby
#source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "9.0"

#这一行必须要添加
use_frameworks!

target 'PLVRtmpDemo' do
    pod 'PLVLiveKit', '~> 1.2.4'
    pod 'PolyvLiveAPI', '~> 0.9.0'
    pod 'PolyvBusinessSDK', '~> 0.15.0'
    # 如果同时集成云课堂SDK，移除 PolyvBusinessSDK 即可
    #pod 'PolyvCloudClassSDK', '~> 0.13' # 最低0.13版本

    # Third Part
    pod 'Masonry', '~> 1.1'
    pod 'ZYCornerRadius', '~> 1.0.2'
    pod 'SDWebImage', '~> 3.8'

    # ---- U-Share SDK
    pod 'UMengUShare/Social/Sina', '~> 6.3.0'
    pod 'UMengUShare/Social/WeChat', '~> 6.3.0'
    pod 'UMengUShare/Social/QQ' , '~> 6.3.0'
end
```
如果同时集成PLVLiveScenesSDK，产生冲突需要修改为以下podfile

```ruby
platform :ios, "9.0"

use_frameworks!

target 'PLVRtmpDemo' do
  #pod 'PolyvBusinessSDK', '~> 0.15.0'
  pod'PolyvSocketAPI/Core', '~> 0.15.0'
  pod'PLVLiveScenesSDK', '~> 1.2.2'
end
```

然后，执行 `pod install` 或 `pod update` 命令。

**暂未提供非 pod 下载方式集成**

`PolyvLiveAPI` [项目地址](https://github.com/polyv/PolyvLiveAPI)

`PolyvSocketAPI` [项目地址](https://github.com/polyv/PolyvSocketAPI)

### 6 项目配置

#### 6.1 添加权限

本项目需要使用到设备的麦克风和摄像头，需要在项目的 info.plist 中配置以下 key 值：

- Privacy - Microphone Usage Description
- Privacy - Camera Usage Description

#### 6.2 支持横竖屏

本项目支持横竖屏播放，选择 Targets 的 General 菜单栏，在 Deployment Info 中的 Device Orientation 进行设置。

### 7 代码示例

详细直播模块可以参考 PLVLiveViewController 类文件

```
#PLVLiveViewController 文件结构

#pragma mark - Life Cycle
#pragma mark - View Control
#pragma mark - Private
#pragma mark - 【网络监测】
#pragma mark - 【弹幕模块】
#pragma mark - 【推流模块】
#pragma mark - 【聊天室模块】
```

#### 7.1 直播推流

```objective-c
/// 倒计时结束回调
- (void)countdownViewDidEnd:(PLVCountdownView *)countdownView{
    self.maskView.hidden = NO;
    self.liveSession.running = YES;
    self.pinchGesture.enabled = YES;
    
    if (self.urlRTMP && self.urlRTMP.length) {
        [self startLive];
    }else {
        [self restartLive];
    }
    [self setStreamModeAndTimer];
    
    [self initChatRoom];
    [self configDanmu];
}

#pragma mark - 【推流模块】

- (LFLiveSession *)liveSession{
    if (!_liveSession) {
        _liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfigWithSetting(self.setting) videoConfiguration:videoConfigWithSetting(self.setting) captureType:LFLiveCaptureDefaultMask];
        _liveSession.captureDevicePosition = AVCaptureDevicePositionBack;   // 开启后置摄像头(默认前置)
        _liveSession.delegate = self;
        _liveSession.showDebugInfo = YES;
        _liveSession.preView = self.previewView;
        _liveSession.reconnectCount = 3;
        _liveSession.reconnectInterval = 3;
        _liveSession.beautyFace = self.setting.beautyEnable;
        NSLog(@"create LFLiveSession");
    }
    return _liveSession;
}

//开始推流
- (void)startLive {
    if (!self.urlRTMP || !self.urlRTMP.length) {
        [self.maskView setShowRetryButton:YES];
        [self showAlertWithErrorMessage:@"当前网络不佳，请稍后再试 #100"];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        LFLiveStreamInfo *streamInfo = [LFLiveStreamInfo new];
        streamInfo.appVersionInfo = APP_VERSION;
        [streamInfo setUrl:self.urlRTMP];
        [self.liveSession startLive:streamInfo];
    });
}

//结束推流
- (void)endLive {
    self.countdownView.hidden = YES;
    self.maskView.hidden = NO;
    [self.liveSession stopLive];
    [self.maskView setLiveSpeed:0];
    [[PLVTimerManager sharedTimerManager] cancelAllTimer];
}


```

#### 7.2 聊天室

```objective-c
#pragma mark - 【聊天室模块】

- (void)initChatRoom {
    [self clearSocketObject];
    
    __weak typeof(self)weakSelf = self;
    PLVChannel *channel = [PLVChannel sharedChannel];
    if (!channel.channelId.length || !channel.appId.length || !channel.appSecret.length) {
        [PLVUtil alertErrorWithTitle:@"聊天室无法连接" reason:@"channelId、appId或appSecret为空" target:self];
        return;
    }
    
    NSString *nickName = [NSString new];
    if (channel.isMasterAccount) {
        nickName = @"主持人";
    }else {
        nickName = channel.channelAccountList[channel.accountId];
    }
    
    // 初始化 socket 登录对象（昵称和头像使用默认设置）
    self.login = [PLVSocketObject socketObjectForLoginEventWithRoomId:channel.chatRoomId.integerValue nickName:nickName avatar:self.setting.urlAvatar userType:PLVSocketObjectUserTypeTeacher];
    
    [PLVNetworking getChatTokenWithChannelId:channel.channelId.integerValue role:@"teacher" userId:self.login.userId appld:channel.appId appSecret:channel.appSecret completion:^(NSDictionary *responseDict) {
        // 初始化 socketIO 连接对象
        weakSelf.socketIO = [[PLVSocketIO alloc] initSocketIOWithConnectToken:responseDict[@"chat_token"] enableLog:NO];
        weakSelf.socketIO.delegate = weakSelf;
        [weakSelf.socketIO connect];
        //weakSelf.socketIO.debugMode = YES;
    } failure:^(PLVLiveErrorCode errorCode, NSString *description) {
        NSLog(@"获取Socket授权失败: %ld, %@", errorCode,description);
        [PLVUtil alertErrorWithTitle:@"聊天室未连接" reason:description target:self];
    }];
    
}

- (void)socketIO:(PLVSocketIO *)socketIO didConnectWithInfo:(NSString *)info {
    NSLog(@"%@--%@",NSStringFromSelector(_cmd),info);
    // 登录 Socket 服务器
    __weak typeof(self)weakSelf = self;
    [socketIO loginSocketServer:self.login timeout:12.0 callback:^(NSArray *ackArray) {
        NSLog(@"login ackArray: %@",ackArray);
        if (ackArray) {
            NSString *ackStr = [NSString stringWithFormat:@"%@",ackArray.firstObject];
            if (ackStr && ackStr.length > 4) {
                int status = [[ackStr substringToIndex:1] intValue];
                if (status == 2) {
                    weakSelf.loginSuccess = YES;
                    [PLVUtil showHUDViewWithMessage:@"登录成功" superView:weakSelf.view];
                } else {
                    [weakSelf loginToSocketFailed:ackStr];
                }
            } else {
                [weakSelf loginToSocketFailed:ackStr];
            }
        }
    }];
}

//聊天室断开连接
- (void)clearSocketObject {
    if (self.socketIO) {
        [self.socketIO disconnect];
        [self.socketIO removeAllHandlers];
        self.socketIO.delegate = nil;
        self.socketIO = nil;
    }
}
```

#### 7.3 弹幕

```objective-c
#pragma mark - 【弹幕模块】

- (void)configDanmu {
    CGRect bounds = self.maskView.bounds;
    if (self.setting.landscapeEnable) {
        self.danmuLayer = [[ZJZDanMu alloc] initWithFrame:CGRectMake(0, 20, bounds.size.width, bounds.size.height-20)];
    }else {
        self.danmuLayer = [[ZJZDanMu alloc] initWithFrame:CGRectMake(0, 125, bounds.size.width, bounds.size.height-20)];
    }
    [self.maskView insertSubview:self.danmuLayer atIndex:0];
}


// 发送弹幕
- (void)sendDaumuWithTitle:(NSString *)title content:(NSString *)content style:(ZJZDMLStyle)style {
    if (!content || [content isKindOfClass:[NSNull class]]) return;
    if (self.danmuLayer) {
        @try {
            // [UIFont systemFontOfSize:14] 不可单独修改，需要和ZJZDanMuLabel中title值一直，否则会影响显示内容
            NSMutableAttributedString *attributedStr = [[PLVEmojiManager sharedManager] convertTextEmotionToAttachment:content font:[UIFont systemFontOfSize:14]];
            [self.danmuLayer insertDMLTitle:title attriContent:attributedStr style:style];
        } @catch (NSException *exception) {
            NSLog(@"弹幕插入失败：%@",exception.reason);
            [self.danmuLayer insertDML:content];
        }
    }
}
```

### 8 FAQ（常见问题）

#### 8.1 编译时控制台输出 “image not found”

基本为 SocketIO swift 库加载问题，如您的项目中为自动配置 Swift 版本，可尝试手动配置，Targets -> Build Settings -> User-Defined 添加 SWIFT_VERSION 字段，设置值为 4.2。

#### 8.2 Socket.io 冲突问题

出现 `Socket.IO-Client-Swift` 库冲突时可以以下方式解决，将 pod 'PolyvSocketAPI' 更新为 pod 'PolyvSocketAPI/Core'（PolyvSocketAPI的子依赖库Core不含Socket.IO-Client-Swift依赖）

如 `pod 'PolyvSocketAPI', '~> 0.6.1'` 等同

```ruby
pod 'PolyvSocketAPI/Core', '~> 0.6.1'
pod 'Socket.IO-Client-Swift', '~> 14.0.0'
```

或 `pod 'PolyvBusinessSDK', '~> 0.15.0'` 等同

```ruby
pod 'PolyvBusinessSDK/Core', '~> 0.6.1'
pod 'Socket.IO-Client-Swift', '~> 14.0.0'
```


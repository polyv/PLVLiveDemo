//
//  PLVLiveController.m
//  LiveStreamer
//
//  Created by LinBq on 16/10/12.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import "PLVLiveViewController.h"
#import "PLVLiveMaskView+VM.h"
#import <PLVLiveKit/LFLiveKit.h>
#import <PLVLiveSDK/PLVNetworking.h>
#import "PLVViewer.h"
#import "SDWebImageManager.h"
#import "PLVTimerManager.h"
#import "PLVCountdownView.h"
#import "PLVLiveEndView.h"
#import "UIImageView+WebCache.h"
#import "PLVUtil.h"
#import "PLVReachabilityManager.h"
#import "ZJZDanMu.h"
#import "PLVEmojiManager.h"
#import <Masonry/Masonry.h>
#import "PLVLiveMaskView.h"

#if __has_include(<PLVSocketAPI/PLVSocketAPI.h>)
    #import <PLVSocketAPI/PLVSocketAPI.h>
#elif __has_include(<PolyvBusinessSDK/PLVSocketIO.h>)
    #import <PolyvBusinessSDK/PLVSocketIO.h>
#endif

#define LIVE_TIME_COUNT_TIMER @"liveTimeCountTimer"

@interface PLVLiveViewController () <LFLiveSessionDelegate, PLVCountdownViewDelegate, PLVSocketIODelegate, UIGestureRecognizerDelegate>

/// 内容视图
@property (strong, nonatomic) UIView *previewView;
@property (nonatomic, strong) PLVLiveMaskView *maskView;
@property (strong, nonatomic) PLVCountdownView *countdownView;

/// 提示视图，防止出现提示信息时挡住button的点击事件
@property (nonatomic, strong) UIView *hudView;

@property (nonatomic, strong) LFLiveSession *liveSession;
@property (nonatomic, strong) NSString *urlRTMP;
@property (nonatomic, assign) CGFloat liveSpeed;

// 即时通信
@property (nonatomic, strong) PLVSocketIO *socketIO;
// Socket 登录对象
@property (nonatomic, strong) PLVSocketObject *login;
// Socket 登录成功
@property (nonatomic, assign) BOOL loginSuccess;
// 推流中断前的累积推流时间
@property (nonatomic, assign) long lastTime;

@property (nonatomic, strong) ZJZDanMu *danmuLayer;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@end

LFLiveVideoConfiguration *videoConfigWithSetting(PLVLiveSetting *setting) {
    LFLiveVideoConfiguration *videoConfig = [[LFLiveVideoConfiguration alloc] init];
    videoConfig.autorotate = YES;
    if (@available(iOS 14.0, *)) {
        videoConfig.videoSize = CGSizeMake(setting.videoSize.width * 0.9, setting.videoSize.height * 0.9);
    } else {
        videoConfig.videoSize = setting.videoSize;
    }

    videoConfig.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    videoConfig.videoFrameRate = 25;
    videoConfig.videoMaxKeyframeInterval = 50;
    
    switch (setting.definition) {
        case PLVDefinitionStandard: {   // 标清
            videoConfig.videoBitRate = 600 * 1000;  // 0.6Mkps
            videoConfig.videoMinBitRate = 500 * 1000;
            videoConfig.videoMaxBitRate = 700 * 1000;
            videoConfig.sessionPreset = LFCaptureSessionPreset360x640;
        } break;
        case PLVDefinitionHigh: {       // 高清
            videoConfig.videoBitRate = 1000 * 1000;  // 1Mkps
            videoConfig.videoMinBitRate = 900 * 1000;
            videoConfig.videoMaxBitRate = 1100 * 1000;
            videoConfig.sessionPreset = LFCaptureSessionPreset540x960;
        } break;
        case PLVDefinitionUltra: {       // 超清
            videoConfig.videoBitRate = setting.maxRate * 1000;
            videoConfig.videoMinBitRate = setting.maxRate * 1000 - 150;
            videoConfig.videoMaxBitRate = setting.maxRate * 1000 + 150;
            videoConfig.sessionPreset = LFCaptureSessionPreset720x1280;
        } break;
    }
    return videoConfig;
}

LFLiveAudioConfiguration *audioConfigWithSetting(PLVLiveSetting *setting){
    switch (setting.definition) {
        case PLVDefinitionStandard:
            return [LFLiveAudioConfiguration defaultConfigurationForQuality:LFLiveAudioQuality_Low];
            break;
        case PLVDefinitionHigh:
            return [LFLiveAudioConfiguration defaultConfigurationForQuality:LFLiveAudioQuality_Medium];
            break;
        case PLVDefinitionUltra:
            return [LFLiveAudioConfiguration defaultConfigurationForQuality:LFLiveAudioQuality_High];
            break;
    }
}

/// 直播状态
NSString *LiveStatusStringWithLFLiveState(LFLiveState status){
    switch (status) {
        case LFLivePending: return @"连接中";
        case LFLiveStart: return @"已连接";
        case LFLiveStop: return @"已断开";
        case LFLiveError: return @"连接出错";
        case LFLiveRefresh: return @"正在刷新";
        default: return @"准备";
    }
}

/// 直播错误信息
NSString *ErrorCodeStringWithLFLiveSocketErrorCode(LFLiveSocketErrorCode errorCode) {
    switch (errorCode) {
        case LFLiveSocketError_PreView: return @"预览失败";
        case LFLiveSocketError_GetStreamInfo: return @"获取流媒体信息失败";
        case LFLiveSocketError_ConnectSocket: return @"连接socket失败";
        case LFLiveSocketError_Verification: return @"验证服务器失败";
        case LFLiveSocketError_ReConnectTimeOut: return @"重新连接服务器超时";
        default:
            return [NSString stringWithFormat:@"%lu",errorCode];
    }
}

@implementation PLVLiveViewController {
    CGFloat _currentZoomFactor;
    BOOL _firstLogin;
}

#pragma mark - Setter/Getter

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
        _liveSession.mirror = self.setting.mirrorEnable;
        NSLog(@"create LFLiveSession");
    }
    return _liveSession;
}

- (NSString *)urlRTMP {
    if (!_urlRTMP) {
        _urlRTMP = [NSString new];
    }
    return _urlRTMP;
}

- (UIView *)hudView {
    if (!_hudView) {
        _hudView = [[UIView alloc]init];
        _hudView.backgroundColor = [UIColor clearColor];
    }
    return _hudView;
}

#pragma mark - Life cycle

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    
    [[PLVTimerManager sharedTimerManager] cancelTimerWithName:VIEWER_LIST_FETCH_TIMER];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstLogin = YES;
    [self setupUI];
    [self commonInit];
    [self setupAV];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    /// 倒计时
    self.countdownView = [[PLVCountdownView alloc]init];
    [self.previewView addSubview:self.countdownView];
    [self.countdownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0);
    }];
    self.countdownView.delegate = self;
    [self.countdownView beginCountdown];

    //[self testCode];
}

#pragma mark - Initialize

- (void)commonInit {
    [self.maskView.closeBtn addTarget:self action:@selector(endLive:) forControlEvents:UIControlEventTouchUpInside];
    [self.maskView.micBtn addTarget:self action:@selector(micSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.maskView.beautyBtn addTarget:self action:@selector(beautySwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.maskView.barrageBtn addTarget:self action:@selector(barrageSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.maskView.camBtn addTarget:self action:@selector(camSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.maskView.flashBtn addTarget:self action:@selector(flashSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.maskView.mirrorBtn addTarget:self action:@selector(mirrorSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.maskView.retryBtn addTarget:self action:@selector(retryBtnBeClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置默认开关值
    self.maskView.beautyBtn.selected = !self.setting.beautyEnable;
    self.maskView.mirrorBtn.selected = !self.setting.mirrorEnable;
        
    __weak typeof(self) weakSelf = self;
    [self.setting requestUrlRtmpWithCompletionHandler:^(NSString *urlRTMP) {
        NSLog(@"init urlRTMP = %@", urlRTMP);
        if (urlRTMP && urlRTMP.length) {
            weakSelf.urlRTMP = urlRTMP;
        }
    }];
    
    [[PLVReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(PLVReachabilityStatus status) {
        NSLog(@"status = %@", [PLVReachabilityManager sharedManager].localizedNetworkReachabilityStatusString);
        if (status == PLVReachabilityStatusNotReachable) {
            [weakSelf endLive];
            [weakSelf.maskView setLiveStatus:@"网络中断"];
            [weakSelf showAlertWithErrorMessage:@"网络连接失败，请稍后重试"];
        } else {
            [PLVUtil alertInfoWithTitle:@"网络已连接" info:@"准备直播" target:weakSelf completionHandler:^{
                [weakSelf.countdownView beginCountdown];
                [weakSelf.maskView fetchViewerListWithInterval:6.0];
            }];
        }
    }];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1];
    self.previewView = [[UIView alloc]init];
    [self.view addSubview:self.previewView];
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        } else {
            make.left.right.mas_offset(0);
        }
        make.top.bottom.mas_offset(0);
    }];
    

    self.maskView = [[PLVLiveMaskView alloc]init];
    [self.previewView addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.previewView.mas_safeAreaLayoutGuideBottom);
            make.top.equalTo(self.previewView.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.mas_offset(0);
            make.bottom.mas_offset(0);
        }
        make.left.right.mas_offset(0);
    }];
    self.maskView.backgroundColor = [UIColor clearColor];
    self.maskView.hidden = YES;
    // 头像、观众列表
    [self.maskView.channelAvatar.avatarView sd_setImageWithURL:[NSURL URLWithString:self.setting.urlAvatar]];
    [self.maskView fetchViewerListWithInterval:6.0];
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    self.pinchGesture.delegate = self;
    self.pinchGesture.enabled = NO;
    [self.view addGestureRecognizer:self.pinchGesture];
    
    [self.previewView addSubview:self.hudView];
    [self.hudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_offset(0);
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];
    
}

- (void)setupAV {
    __weak typeof(self) weakSelf = self;
    [PLVUtil requestAccessForVideoWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.liveSession setRunning:YES];
        });
    }];
    [PLVUtil requestAccessForAudio];
}

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

- (void)configDanmu {
    CGRect bounds = self.maskView.bounds;
    if (self.setting.landscapeEnable) {
        self.danmuLayer = [[ZJZDanMu alloc] initWithFrame:CGRectMake(0, 20, bounds.size.width, bounds.size.height-20)];
    }else {
        self.danmuLayer = [[ZJZDanMu alloc] initWithFrame:CGRectMake(0, 125, bounds.size.width, bounds.size.height-20)];
    }
    [self.maskView insertSubview:self.danmuLayer atIndex:0];
}

/// 设置流模式和开启定时器
- (void)setStreamModeAndTimer {
    PLVChannel *channel = [PLVChannel sharedChannel];
    NSUInteger videoWidth = self.setting.videoSize.width;
    NSUInteger videoHeight = self.setting.videoSize.height;
    
    __weak typeof(self) weakSelf = self;
    [PLVNetworking notifyStreamModeWithChannelId:channel.channelId stream:channel.streamName videoWidth:videoWidth videoHeight:videoHeight completion:^(NSString *responseCont) {
        [weakSelf startCountdown];
    } failure:^(PLVLiveErrorCode errorCode, NSString *description) {
        NSLog(@"notifyStreamModeWithChannelId failed: %ld, %@",errorCode,description);
        [weakSelf startCountdown];
    }];
}

- (void)startCountdown {
    __block long count = self.lastTime;
    __block CGFloat lastSpeed;
    __weak typeof(self) weakSelf = self;
    [[PLVTimerManager sharedTimerManager] scheduledDispatchTimerWithName:LIVE_TIME_COUNT_TIMER timeInterval:1.0 queue:nil repeats:YES actionOption:AbandonPreviousAction action:^{
        count ++;
        self.lastTime = count;
        [weakSelf.maskView setLiveTime:count];
        if (lastSpeed == weakSelf.liveSpeed) {
            weakSelf.liveSpeed = 0;
            [weakSelf.maskView setLiveSpeed:0];
        }
        lastSpeed = weakSelf.liveSpeed;
    }];
}

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
        self.liveSession.running = YES;
        [self.liveSession startLive:streamInfo];
    });
}

- (void)restartLive {
    [self.liveSession stopLive];
    
    __weak typeof(self) weakSelf = self;
    [self.setting requestUrlRtmpWithCompletionHandler:^(NSString *urlRTMP) {
        NSLog(@"urlRTMP = %@", urlRTMP);
        weakSelf.urlRTMP = urlRTMP;
        [weakSelf startLive];
        self.liveSession.running = YES;
        [self startCountdown];
    }];
    
    if (self.socketIO) {
        switch (self.socketIO.socketIOState) {
            case PLVSocketIOStatusNotConnected:
            case PLVSocketIOStateDisconnected:
            case PLVSocketIOStateConnectError: {
                [self.socketIO reconnect];
            } break;
            default: break;
        }
    }
}

- (void)endLive {
    self.countdownView.hidden = YES;
    self.maskView.hidden = NO;
    [self.liveSession stopLive];
    [self.maskView setLiveSpeed:0];
    [[PLVTimerManager sharedTimerManager] cancelAllTimer];
    self.liveSession.running = NO;
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

- (void)showAlertWithErrorMessage:(NSString *)message {
    __weak typeof(self)weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"当前直播已停止" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf restartLive];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)clearSocketObject {
    if (self.socketIO) {
        [self.socketIO disconnect];
        [self.socketIO removeAllHandlers];
        self.socketIO.delegate = nil;
        self.socketIO = nil;
    }
}

#pragma mark - Actions

- (void)close:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        self.liveSession = nil;
    }];
}

- (void)retryBtnBeClicked:(UIButton *)sender {
    [self restartLive];
}

- (void)endLive:(id)sender {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定要结束直播吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self clearSocketObject];     //  关闭聊天室
        
        [weakSelf endLive];
        PLVLiveEndView *endView = [[PLVLiveEndView alloc] initWithFrame:weakSelf.view.bounds];
        [endView setLivePopulation:weakSelf.maskView.viewerCount];
        [endView setLiveTime:weakSelf.maskView.liveTime];
        [weakSelf.maskView removeFromSuperview];
        [weakSelf.view addSubview:endView];
        [endView.endButton addTarget:weakSelf action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    }];
    [alert addAction:cancel];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)micSwitch:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.liveSession.muted = sender.isSelected;
    [PLVUtil showHUDViewWithMessage:sender.isSelected?@"静音模式":@"关闭静音" superView:self.hudView];
}

- (void)beautySwitch:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.liveSession.beautyFace = !sender.isSelected;
    [PLVUtil showHUDViewWithMessage:sender.isSelected?@"关闭美颜":@"美颜模式" superView:self.hudView];
}

- (void)barrageSwitch:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [self.danmuLayer setHidden:sender.isSelected];
    [PLVUtil showHUDViewWithMessage:sender.isSelected?@"关闭弹幕":@"显示弹幕" superView:self.hudView];
}

- (void)camSwitch:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    AVCaptureDevicePosition devicePosition = self.liveSession.captureDevicePosition;
    self.liveSession.captureDevicePosition = (devicePosition == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    self.maskView.flashBtn.enabled = self.liveSession.captureDevicePosition == AVCaptureDevicePositionBack;
    [PLVUtil showHUDViewWithMessage:@"切换摄像头" superView:self.hudView];
}

- (void)flashSwitch:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.liveSession.torch = sender.isSelected;
    [PLVUtil showHUDViewWithMessage:sender.isSelected?@"开启闪光灯":@"关闭闪光灯" superView:self.hudView];
}

- (void)mirrorSwitch:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.liveSession.mirror = !sender.isSelected;
    [PLVUtil showHUDViewWithMessage:sender.isSelected?@"关闭镜像":@"开启镜像" superView:self.hudView];
}

#pragma mark UIGestureRecognizer

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer {
    //NSLog(@"scale:%lf",recognizer.scale);
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            CGFloat currentZoomFactor = _currentZoomFactor * recognizer.scale;
            if (currentZoomFactor >= 1.0 && currentZoomFactor <= 3.0){
                self.liveSession.zoomScale = currentZoomFactor;
            }
        } break;
        default:
            break;
    }
}

#pragma mark - <UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        _currentZoomFactor = self.liveSession.zoomScale;
    }

    return YES;
}

#pragma mark - <PLVCountdownViewDelegate>
/// 倒计时结束回调
- (void)countdownViewDidEnd:(PLVCountdownView *)countdownView{
    self.maskView.hidden = NO;
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

#pragma mark - <LFLiveSessionDelegate>

- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    NSString *statusString = LiveStatusStringWithLFLiveState(state);
    NSLog(@"liveStateDidChange: %@", statusString);
    switch (state) {
        case LFLiveStop:
        case LFLiveError: {
            [self.maskView setShowRetryButton:YES];
            [self.maskView setLiveStatus:statusString color:[UIColor redColor]];
        } break;
        default: {
            [self.maskView setShowRetryButton:NO];
            [self.maskView setLiveStatus:statusString color:[UIColor whiteColor]];
        } break;
    }
}

- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo {
    //    NSLog(@"debugInfo uploadSpeed: %@", formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli));
    //    NSLog(@"debugInfo = %@", debugInfo);
    CGFloat speed = debugInfo.currentBandwidth * 1000.0 / debugInfo.elapsedMilli;
    self.liveSpeed = speed;
    [self.maskView setLiveSpeed:speed];
}

- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
    NSLog(@"%@ %@",NSStringFromSelector(_cmd),ErrorCodeStringWithLFLiveSocketErrorCode(errorCode));
    [self endLive];
    [self showAlertWithErrorMessage:[NSString stringWithFormat:@"推流失败，请重新推流！ #%lu",errorCode]];
    [self.maskView setShowRetryButton:YES];
    [self.maskView setLiveStatus:@"已断开" color:[UIColor redColor]];
}

#pragma mark - <PLVSocketIODelegate>

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

/*
登陆LOGIN事件ack返回的数据格式改为一个整数，整数每位表示如下：
第1位：登陆结果，2表示成功，4表示传递参数非法等问题，5表示报错
第2位：房间是否合法，即找不到房间id，或者房间id类型不正确，1表示合法，0表示非法
第3位：头像昵称错误，1表示正确，0表示错误
第4位：是否被踢出，1表示没有被踢出房间，0表示已被踢出房间
第5位：是否被禁言，1表示没有被禁言，0表示被禁言
 */
- (void)loginToSocketFailed:(NSString *)ackStr {
    [self.socketIO disconnect];
    self.loginSuccess = NO;
    [PLVUtil showHUDViewWithMessage:[NSString stringWithFormat:@"登录失败：%@",ackStr] superView:self.view];
}

- (void)socketIO:(PLVSocketIO *)socketIO didReceivePublicChatMessage:(PLVSocketChatRoomObject *)chatObject {
    NSLog(@"%@--type:%lu, event:%@",NSStringFromSelector(_cmd),chatObject.eventType,chatObject.event);
    NSDictionary *user = chatObject.jsonDict[PLVSocketIOChatRoom_SPEAK_userKey];
    switch (chatObject.eventType) {
        case PLVSocketChatRoomEventType_LOGIN: {
            NSString *userId = [NSString stringWithFormat:@"%@",user[PLVSocketIOChatRoomUserUserIdKey]];
            if (_firstLogin) {
                _firstLogin = NO;
                self.maskView.viewerCount = [chatObject.jsonDict[@"onlineUserNumber"] unsignedIntegerValue];
            } else if (![userId isEqualToString:self.login.userId]) {
                self.maskView.viewerCount ++;
            }
        } break;
        case PLVSocketChatRoomEventType_GONGGAO: {  // 1.2.管理员发言/跑马灯公告
            NSString *content = chatObject.jsonDict[PLVSocketIOChatRoom_GONGGAO_content];
            [self sendDaumuWithTitle:@"管理员发言" content:content style:ZJZDMLFade];
        } break;
        case PLVSocketChatRoomEventType_BULLETIN: { // 1.3.公告
            NSString *content = chatObject.jsonDict[PLVSocketIOChatRoom_BULLETIN_content];
            [self sendDaumuWithTitle:@"公告" content:content style:ZJZDMLFade];
        } break;
        case PLVSocketChatRoomEventType_SPEAK: {    // 1.4.用户发言
            if (user) {     // use不存在时可能为严禁词类型；开启聊天审核后会收到自己数据
                NSString *userId = [NSString stringWithFormat:@"%@",user[PLVSocketIOChatRoomUserUserIdKey]];
                if ([userId isEqualToString:self.login.userId]) {
                    break;
                }
                NSString *nickname = chatObject.jsonDict[PLVSocketIOChatRoom_SPEAK_userKey][PLVSocketIOChatRoomUserNickKey];
                NSString *speakContent = [chatObject.jsonDict[PLVSocketIOChatRoom_SPEAK_values] firstObject];
                [self sendDaumuWithTitle:nickname content:speakContent style:ZJZDMLRoll];
            }
        } break;
        case PLVSocketChatRoomEventType_CLOSEROOM: {
            NSDictionary *value = chatObject.jsonDict[@"value"];
            if ([value[@"closed"] boolValue]) {
                [self sendDaumuWithTitle:@"系统信息" content:@"房间暂时关闭" style:ZJZDMLFade];
            } else {
                [self sendDaumuWithTitle:@"系统信息" content:@"房间已经打开" style:ZJZDMLFade];
            }
        } break;
        default: break;
    }
}

- (void)socketIO:(PLVSocketIO *)socketIO didDisconnectWithInfo:(NSString *)info {
    NSLog(@"%@--%@",NSStringFromSelector(_cmd),info);
    self.loginSuccess = NO;
    [self sendDaumuWithTitle:@"系统信息" content:@"聊天室断开" style:ZJZDMLFade];
}

- (void)socketIO:(PLVSocketIO *)socketIO connectOnErrorWithInfo:(NSString *)info {
    NSLog(@"%@--%@",NSStringFromSelector(_cmd),info);
    // TODO:重连逻辑，6s后 [socketIO reconnect];
    [self sendDaumuWithTitle:@"系统信息" content:@"聊天室连接出错" style:ZJZDMLFade];
}

- (void)socketIO:(PLVSocketIO *)socketIO reconnectWithInfo:(NSString *)info {
    NSLog(@"%@--%@",NSStringFromSelector(_cmd),info);
}

- (void)socketIO:(PLVSocketIO *)socketIO localError:(NSString *)description {
    NSLog(@"%@--%@",NSStringFromSelector(_cmd),description);
}

#pragma mark - View control

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.setting.landscapeEnable) {
        return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotate {
    return self.setting.landscapeEnable;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Test

- (void)testCode {
    UIButton *connectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [connectBtn setTitle:@"连接" forState:UIControlStateNormal];
    [self.maskView addSubview:connectBtn];
    //connectBtn.center = CGPointMake(self.maskView.center.x, 30);
    [connectBtn addTarget:self action:@selector(connectRTMP:) forControlEvents:UIControlEventTouchUpInside];
    [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.maskView.center);
    }];
}

- (void)connectRTMP:(UIButton *)sender{
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        __weak typeof(self) weakSelf = self;
        [self.setting requestUrlRtmpWithCompletionHandler:^(NSString *urlRTMP) {
            LFLiveStreamInfo *streamInfo = [[LFLiveStreamInfo alloc] init];
            streamInfo.url = urlRTMP;
            [weakSelf.liveSession startLive:streamInfo];
        }];
    }else{
        [self.liveSession stopLive];
    }
}


@end

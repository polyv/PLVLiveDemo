//
//  PLVLiveMaskView.h
//  LiveStreamer
//
//  Created by LinBq on 16/10/20.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVChanelAvatarView.h"
#import "PLVViewer.h"

//IB_DESIGNABLE
@interface PLVLiveMaskView : UIView

#pragma mark 控件
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UIButton *micBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *beautyBtn;
@property (weak, nonatomic) IBOutlet UIButton *barrageBtn;
@property (weak, nonatomic) IBOutlet UIButton *camBtn;
@property (weak, nonatomic) IBOutlet UIButton *flashBtn;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
@property (weak, nonatomic) IBOutlet UIButton *mirrorBtn;

#pragma mark 头像视图
@property (weak, nonatomic) IBOutlet PLVChanelAvatarView *channelAvatar;

/// 直播时间
@property (nonatomic, assign) long liveTime;

/// 显示重试按钮
@property (nonatomic, assign) BOOL showRetryButton;

#pragma mark 观众列表
/// 合并传递过来的观众列表
- (void)mergeViewerWithViewerList:(NSArray<PLVViewer *> *)viewerList;

/// 网速
- (void)setLiveSpeed:(CGFloat)speed;
/// 设置网速状态
- (void)setLiveStatus:(NSString *)text;
/// 设置直播状态
- (void)setLiveStatus:(NSString *)text color:(UIColor *)color;

@property (nonatomic, assign) BOOL logEnable;
/// 累计人数
@property (nonatomic, assign) long viewerCount;

@end
